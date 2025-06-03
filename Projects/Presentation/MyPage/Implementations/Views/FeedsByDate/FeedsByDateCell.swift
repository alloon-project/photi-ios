//
//  FeedsByDateCell.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import DesignSystem
import Core

final class FeedsByDateCell: UICollectionViewCell {
  // MARK: - Properties
  fileprivate var challengeId: Int = 0
  fileprivate var feedId: Int = 0
  
  // MARK: - UI Components
  private let provedTimeChip = TextChip(type: .green, size: .large)
  private let titleView = FeedsByDateTitleView()
  private let seperatorView = UIView()
  fileprivate let challengeImageView = FeedsByDateImageView()
  
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
  func configure(with model: FeedsByDatePresentationModel, isLast: Bool) {
    self.challengeId = model.challengeId
    self.feedId = model.feedId
    
    configureSeperatorView(isLast: isLast)
    titleView.title = model.title
    challengeImageView.configure(with: model.feedImageViewUrl)
    provedTimeChip.text = model.provedTime
  }
}

// MARK: - UI Methods
private extension FeedsByDateCell {
  func setupUI() {
    challengeImageView.transform = challengeImageView.transform.rotated(by: .pi * -2 / 180)
    seperatorView.backgroundColor = .green100
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(provedTimeChip, titleView, seperatorView, challengeImageView)
  }
  
  func setConstraints() {
    provedTimeChip.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    seperatorView.snp.makeConstraints {
      $0.leading.equalTo(provedTimeChip.snp.trailing).offset(14)
      $0.trailing.equalToSuperview()
      $0.height.equalTo(2)
      $0.centerY.equalTo(provedTimeChip)
    }
    
    titleView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(provedTimeChip.snp.bottom).offset(16)
      $0.height.equalTo(78)
    }
    
    challengeImageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(52)
      $0.height.equalTo(challengeImageView.snp.width)
      $0.top.equalTo(titleView).offset(48)
    }
  }
}

// MARK: - Private Methods
private extension FeedsByDateCell {
  func configureSeperatorView(isLast: Bool) {
    seperatorView.isHidden = isLast
  }
}

extension Reactive where Base: FeedsByDateCell {
  var didTapFeed: ControlEvent<(challengeId: Int, feedId: Int)> {
    let source = base.challengeImageView.rx.didTapImage
      .map { _ in (challengeId: base.challengeId, feedId: base.feedId) }
    
    return .init(events: source)
  }
}
