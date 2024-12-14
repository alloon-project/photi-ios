//
//  FeedCell.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Core
import DesignSystem

final class FeedCell: UICollectionViewCell {
  // MARK: - UI Components
  private let imageView = UIImageView()
  private let userNameLabel = UILabel()
  private let updateTimeLabel = UILabel()
  private let likeButton = FeedLikeButton()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(with model: FeedPresentationModel) {
    userNameLabel.attributedText = model.userName.attributedString(font: .body2Bold, color: .white)
    updateTimeLabel.attributedText = model.updateTime.attributedString(font: .caption1, color: .white)
    
    if let url = URL(string: model.imageURL) {
      imageView.kf.setImage(with: url)
    }
  }
}

// MARK: - UI Methods
private extension FeedCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    
    self.roundCorners(
      leftTop: 8,
      rightTop: 8,
      leftBottom: 8,
      rightBottom: 40
    )

    configureShapeBorder(
      width: 3,
      strockColor: .gray200,
      backGroundColor: .clear
    )
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(imageView, userNameLabel, updateTimeLabel, likeButton)
  }
  
  func setConstraints() {
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    userNameLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(14)
      $0.leading.equalToSuperview().offset(13)
    }
    
    updateTimeLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(15)
      $0.trailing.equalToSuperview().inset(13)
    }
    
    likeButton.snp.makeConstraints {
      $0.trailing.bottom.equalToSuperview()
      $0.height.width.equalTo(32)
    }
  }
}
