//
//  FeedCommentTopView.swift
//  ChallengeImpl
//
//  Created by jung on 1/3/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import CoreUI
import DesignSystem

final class FeedCommentTopView: UIView {
  var author: AuthorPresentationModel? {
    didSet {
      guard let author else { return }
      configureAuthor(author)
    }
  }
  
  var updateTime: String = "" {
    didSet { configureUpdateTime(updateTime) }
  }
  
  var likeCount: Int = 0 {
    didSet { configureLikeCount(likeCount) }
  }
  
  var isLike: Bool = false {
    didSet { likeButton.isSelected = isLike }
  }
  
  var isEnbledOptionButton: Bool = false {
    didSet { optionButton.isHidden = !isEnbledOptionButton }
  }
  
  // MARK: - UI Components
  private let topGradientLayer: GradientLayer = {
    let color = UIColor(red: 0.118, green: 0.137, blue: 0.149, alpha: 0.7)
    return .init(mode: .topToBottom, maxColor: color)
  }()
  private let avatarImageView = AvatarImageView(size: .xSmall)
  private let userNameLabel = UILabel()
  private let updateTimeLabel = UILabel()
  fileprivate let likeButton = IconButton(size: .small)
  let optionButton = IconButton(selectedIcon: .ellipsisVerticalWhite, size: .small)
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
      optionButton,
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
    
    optionButton.snp.makeConstraints {
      $0.centerY.equalTo(likeButton)
      $0.trailing.equalTo(likeButton.snp.leading).offset(-12)
    }
    
    likeCountLabel.snp.makeConstraints {
      $0.centerX.equalTo(likeButton)
      $0.top.equalTo(likeButton.snp.bottom).offset(6)
    }
  }
}

// MARK: - Methods
extension FeedCommentTopView {
  func configureAuthor(_ author: AuthorPresentationModel) {
    userNameLabel.attributedText = author.name.attributedString(
      font: .body2Bold,
      color: .white
    )
    
    Task {
      guard
        let imageURL = author.imageURL,
        let result = try? await KingfisherManager.shared.retrieveImage(with: imageURL)
      else { return }
      
      avatarImageView.image = result.image
    }
  }
  
  func configureUpdateTime(_ updateTime: String) {
    updateTimeLabel.attributedText = updateTime.attributedString(
      font: .caption1,
      color: .gray200
    )
  }
  
  func configureLikeCount(_ likeCount: Int) {
    let likeCountText = likeCount == 0 ? "" : "\(likeCount)"
    likeCountLabel.attributedText = likeCountText.attributedString(
      font: .caption1Bold,
      color: .white
    )
  }
}

extension Reactive where Base: FeedCommentTopView {
  var didTapLikeButton: ControlEvent<Bool> {
    let source = base.likeButton.rx.tap.map { _ in base.likeButton.isSelected }
    
    return .init(events: source)
  }
  
  var didTapOptionButton: ControlEvent<Bool> {
    let source = base.optionButton.rx.tap.map { _ in base.optionButton.isSelected }
    
    return .init(events: source)
  }
}
