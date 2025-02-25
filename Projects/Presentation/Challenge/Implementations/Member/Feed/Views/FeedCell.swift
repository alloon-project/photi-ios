//
//  FeedCell.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class FeedCell: UICollectionViewCell {
  fileprivate var feedId: Int = 0
  
  // MARK: - UI Components
  private let dimmedLayer: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4).cgColor
    
    return layer
  }()
  
  private let imageView = UIImageView()
  private let userNameLabel = UILabel()
  private let updateTimeLabel = UILabel()
  fileprivate let likeButton = FeedLikeButton()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    dimmedLayer.frame = .init(origin: .zero, size: bounds.size)
  }
  
  // MARK: - Configure
  func configure(with model: FeedPresentationModel) {
    feedId = model.id
    userNameLabel.attributedText = model.userName.attributedString(font: .body2Bold, color: .white)
    updateTimeLabel.attributedText = model.updateTime.attributedString(font: .caption1, color: .white)
    imageView.kf.setImage(with: model.imageURL)
    likeButton.isSelected = model.isLike
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
    contentView.addSubview(imageView)
    contentView.layer.addSublayer(dimmedLayer)
    contentView.addSubviews(userNameLabel, updateTimeLabel, likeButton)
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

extension Reactive where Base: FeedCell {
  var didTapLikeButton: ControlEvent<(Bool, Int)> {
    let source = base.likeButton.rx.tap.map { _ in
      (base.likeButton.isSelected, base.feedId)
    }
    
    return .init(events: source)
  }
}
