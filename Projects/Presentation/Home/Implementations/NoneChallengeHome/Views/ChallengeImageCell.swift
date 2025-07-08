//
//  ChallengeImageCell.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Core
import DesignSystem

final class ChallengeImageCell: UICollectionViewCell {
  // MARK: - Properties
  var isCurrentPage: Bool = false {
    didSet { setImageView(for: isCurrentPage) }
  }
  
  // MARK: - UI Components
  private var isDefaultImage: Bool = true {
    didSet {
      gradientLayer.isHidden = !(isDefaultImage && isCurrentPage)
    }
  }
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 10
    imageView.clipsToBounds = true
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  private let pinImageView = UIImageView(image: .pinBlue.withRenderingMode(.alwaysOriginal))
  private let gradientLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.colors = [
      UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.2).cgColor,
      UIColor(red: 0.118, green: 0.137, blue: 0.149, alpha: 0).cgColor
    ]
    layer.cornerRadius = 10
    layer.masksToBounds = true

    return layer
  }()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(with viewModel: ChallengePresentationModel) {
    Task {
      guard
        let imageURL = viewModel.imageURL,
        let result = try? await KingfisherManager.shared.retrieveImage(with: imageURL)
      else {
        imageView.image = .defaultChallengeImage
        isDefaultImage = true
        return
      }
      
      imageView.image = result.image
      isDefaultImage = false
    }
  }
  
  func configureCreateCell() {
    imageView.image = .homeMemberCreateChallenge
  }
}

// MARK: - UI Methods
private extension ChallengeImageCell {
  func setupUI() {
    imageView.backgroundColor = .white
    contentView.addSubviews(imageView, pinImageView)
    imageView.layer.addSublayer(gradientLayer)
    gradientLayer.frame = .init(x: 0, y: 0, width: 160, height: 160)
    
    imageView.snp.makeConstraints {
      $0.width.height.equalTo(160)
      $0.bottom.equalToSuperview()
      $0.centerX.equalToSuperview()
    }
    
    pinImageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(imageView.snp.top).offset(-12)
      $0.width.height.equalTo(24)
    }
  }
  
  func setImageView(for isCurrentPage: Bool) {
    pinImageView.isHidden = !isCurrentPage
    self.imageView.alpha = isCurrentPage ? 1.0 : 0.3
    if isCurrentPage {
      UIView.animate(withDuration: 0.1) {
        self.imageView.snp.updateConstraints {
          $0.width.height.equalTo(160)
          $0.bottom.equalToSuperview()
        }
        self.contentView.layoutIfNeeded()
      }
    } else {
      UIView.animate(withDuration: 0.1) {
        self.imageView.snp.updateConstraints {
          $0.width.height.equalTo(140)
          $0.bottom.equalToSuperview().offset(-10)
        }
        self.contentView.layoutIfNeeded()
      }
    }
  }
}
