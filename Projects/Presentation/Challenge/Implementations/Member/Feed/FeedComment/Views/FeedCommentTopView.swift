//
//  FeedCommentTopView.swift
//  ChallengeImpl
//
//  Created by jung on 1/3/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class FeedCommentTopView: UIView {
  // MARK: - UI Components
  private let topGradientLayer = FeedCommentGradientLayer(mode: .topToBottom, maxAlpha: 0.5)
  private let avatarImageView = AvatarImageView(size: .xSmall)
  private let userNameLabel = UILabel()
  private let updateTimeLabel = UILabel()
  private let likeButton = IconButton(size: .small)
  private let likeCountLabel = UILabel()
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    topGradientLayer.frame = bounds
  }
}

// MARK: - UI Methods
private extension FeedCommentTopView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    layer.addSublayer(topGradientLayer)
    addSubviews(
      avatarImageView,
      userNameLabel,
      updateTimeLabel,
      likeButton,
      likeCountLabel
    )
  }
  
  func setConstraints() {
    avatarImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(18)
      $0.top.equalToSuperview().offset(22)
    }
    
    userNameLabel.snp.makeConstraints {
      $0.centerY.equalTo(avatarImageView)
      $0.leading.equalTo(avatarImageView.snp.trailing).offset(6)
    }
    
    updateTimeLabel.snp.makeConstraints {
      $0.centerY.equalTo(avatarImageView)
      $0.leading.equalTo(userNameLabel.snp.trailing).offset(12)
    }
    
    likeButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(18)
    }
    
    likeCountLabel.snp.makeConstraints {
      $0.centerX.equalTo(likeButton)
      $0.top.equalTo(likeButton.snp.bottom).offset(6)
    }
  }
}

// MARK: - Methods
extension FeedCommentTopView {
  func setUserName(_ userName: String) {
    userNameLabel.attributedText = userName.attributedString(
      font: .body2Bold,
      color: .white
    )
  }
  
  func updateTime(_ updateTime: String) {
    updateTimeLabel.attributedText = updateTime.attributedString(
      font: .caption1,
      color: .gray200
    )
  }
  
  func setLikeCount(_ likeCount: Int) {
    let likeCountText = likeCount == 0 ? "" : "\(likeCount)"
    likeCountLabel.attributedText = likeCountText.attributedString(
      font: .caption1Bold,
      color: .gray200
    )
  }
}
