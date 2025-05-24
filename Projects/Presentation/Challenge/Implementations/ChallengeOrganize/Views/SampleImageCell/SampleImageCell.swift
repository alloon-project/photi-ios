//
//  SampleImageCell.swift
//  Presentation
//
//  Created by 임우섭 on 4/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import Core
import DesignSystem

final class SampleImageCell: UICollectionViewCell {
  private var textColor: UIColor {
    isSelected ? .blue400 : .gray800
  }
  private var imageBorderColor: UIColor {
    isSelected ? .blue400 : .white
  }
  
  override var isSelected: Bool {
    didSet {
      setCellColor()
    }
  }

  // MARK: - UI Components
  private let imageBackgroundView = {
    let view = UIView()
    view.layer.cornerRadius = 12
    view.layer.borderColor  = UIColor.white.cgColor
    view.layer.borderWidth = 2
    
    return view
  }()
  
  private let sampleImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 12
    imageView.clipsToBounds = true
    imageView.layer.borderWidth = 2
    imageView.layer.borderColor = UIColor.white.cgColor
    imageView.contentMode = .center
    imageView.backgroundColor = .gray500
    return imageView
  }()
  
  private let imageNameLabel = UILabel()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(with model: SampleImageCellPresentaionModel) {
    if model.imageUrlString == "Photo" { // Default Cell
      sampleImageView.image = .galleryWhite.resize(.init(width: 24, height: 24))
      imageNameLabel.attributedText = "직접 불러오기".attributedString(font: .caption1Bold, color: .gray800)
      imageNameLabel.textAlignment = .center
    } else {
      guard let url = URL(string: model.imageUrlString) else { return }
      KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
        switch result {
        case .success(let value):
          Task { @MainActor in
            self?.sampleImageView.image = value.image.resize(.init(width: 64, height: 64))
          }
        case .failure(let error):
          return
        }
      }
      
      setTempImageName(urlString: model.imageUrlString)
      // TODO: - API에서 이미지 이름 추가예정(?)
      
      imageNameLabel.textAlignment = .center
    }
  }
}

// MARK: - UI Methods
private extension SampleImageCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(
      imageBackgroundView,
      imageNameLabel
    )
    
    imageBackgroundView.addSubview(sampleImageView)
  }
  
  func setConstraints() {
    imageBackgroundView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
      $0.width.height.equalTo(72)
    }
    
    sampleImageView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(2)
    }
    
    imageNameLabel.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(sampleImageView.snp.bottom).offset(10)
    }
  }
}

// MARK: - Private Methods
private extension SampleImageCell {
  func setCellColor() {
    imageNameLabel.attributedText = imageNameLabel.attributedText?.setColor(textColor)
    
    imageBackgroundView.layer.borderColor = imageBorderColor.cgColor
  }
  
  func setTempImageName(urlString: String) {
    if urlString.contains("img_cover_health") {
      imageNameLabel.attributedText = "오운완".attributedString(font: .caption1Bold, color: .gray800)
    }
    if urlString.contains("img_cover_lucky") {
      imageNameLabel.attributedText = "럭키데이".attributedString(font: .caption1Bold, color: .gray800)
    }
    if urlString.contains("img_cover_photo") {
      imageNameLabel.attributedText = "인증샷".attributedString(font: .caption1Bold, color: .gray800)
    }
    if urlString.contains("img_cover_study") {
      imageNameLabel.attributedText = "스터디".attributedString(font: .caption1Bold, color: .gray800)
    }
  }
}
