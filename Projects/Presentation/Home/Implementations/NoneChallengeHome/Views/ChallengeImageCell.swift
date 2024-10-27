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
    didSet {
      self.setImageView(for: isCurrentPage)
    }
  }
  
  // MARK: - UI Components
  private let imageView = UIImageView()
  private let pinImageView = UIImageView(image: .pinBlue)
  
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
    if let url = viewModel.imageURL {
      imageView.kf.setImage(with: url)
    } else {
      imageView.image = .defaultChallengeImage
    }
  }
  
  func configureCreateCell() {
    imageView.image = .createChallenge
  }
}

// MARK: - UI Methods
private extension ChallengeImageCell {
  func setupUI() {
    contentView.addSubviews(imageView, pinImageView)
    
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
      UIView.animate(withDuration: 0.2) {
        self.imageView.snp.updateConstraints {
          $0.width.height.equalTo(160)
          $0.bottom.equalToSuperview()
        }
        self.contentView.layoutSubviews()
      }
    } else {
      UIView.animate(withDuration: 0.2) {
        self.imageView.snp.updateConstraints {
          $0.width.height.equalTo(140)
          $0.bottom.equalToSuperview().offset(-10)
        }
        self.contentView.layoutSubviews()
      }
    }
  }
}
