//
//  FeedHistoryCell.swift
//  Presentation
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Core
import DesignSystem

final class FeedHistoryCell: UICollectionViewCell {
  // MARK: - UI Components
  private let feedImageView = FeedImageView()
  private let challengeTitleChip = TextChip(type: .line, size: .small)
  fileprivate let shareButton: UIButton = {
    let button = UIButton()
    button.setImage(.shortcutGray700, for: .normal)
    
    return button
  }()
  
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
  func configure(with model: FeedCardPresentationModel) {
    feedImageView.configure(with: model)
    challengeTitleChip.text = model.challengeTitle
    shareButton.isHidden = model.isDeleted
  }
}

// MARK: - UI Methods
private extension FeedHistoryCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(feedImageView, challengeTitleChip, shareButton)
  }
  
  func setConstraints() {
    feedImageView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }
    
    challengeTitleChip.snp.makeConstraints {
      $0.top.equalTo(feedImageView.snp.bottom).offset(8)
      $0.leading.bottom.equalToSuperview()
      $0.height.equalTo(23)
      $0.trailing.lessThanOrEqualTo(shareButton.snp.leading).inset(16)
    }
    
    shareButton.snp.makeConstraints {
      $0.trailing.bottom.equalToSuperview().inset(2)
      $0.width.height.equalTo(18)
    }
  }
}

// MARK: - Reactive Extension
extension Reactive where Base: FeedHistoryCell {
  var didTapShareButton: ControlEvent<Void> {
    base.shareButton.rx.tap
  }
}
