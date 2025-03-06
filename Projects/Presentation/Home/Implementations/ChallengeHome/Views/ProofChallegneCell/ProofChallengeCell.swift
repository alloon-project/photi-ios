//
//  ProofChallengeCell.swift
//  HomeImpl
//
//  Created by jung on 10/7/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import DesignSystem
import Core

final class ProofChallengeCell: UICollectionViewCell {
  typealias ModelType = MyChallengeFeedPresentationModel.ModelType
  
  // MARK: - Properties
  private(set) var isLast: Bool = false
  private(set) var challengeId: Int = 0
  
  // MARK: - UI Components
  private let deadLineChip = TextChip(type: .green, size: .large)
  private let titleView = ChallengeTitleView()
  private let seperatorView = UIView()
  fileprivate let challengeImageView = ChallengeImageView()
  
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
  func configure(with model: MyChallengeFeedPresentationModel, isLast: Bool) {
    self.challengeId = model.id
    deadLineChip.text = model.deadLine
    setupUI(type: model.type, isLast: isLast)
    titleView.configure(title: model.title, type: model.type)
    challengeImageView.configure(with: model.type)
  }
}

// MARK: - UI Methods
private extension ProofChallengeCell {
  func setupUI() {
    challengeImageView.transform = challengeImageView.transform.rotated(by: .pi * -2 / 180)
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(deadLineChip, titleView, seperatorView, challengeImageView)
  }
  
  func setConstraints() {
    deadLineChip.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    seperatorView.snp.makeConstraints {
      $0.leading.equalTo(deadLineChip.snp.trailing).offset(14)
      $0.trailing.equalToSuperview()
      $0.height.equalTo(1)
      $0.centerY.equalTo(deadLineChip)
    }
    
    titleView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(deadLineChip.snp.bottom).offset(16)
      $0.height.equalTo(78)
    }
    
    challengeImageView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.height.width.equalTo(184)
      $0.top.equalTo(titleView).offset(48)
    }
  }
}

// MARK: - Private Methods
private extension ProofChallengeCell {
  func setupUI(type: ModelType, isLast: Bool) {
    configureSeperatorView(type: type, isLast: isLast)
    
    switch type {
      case .proofURL, .proofImage:
        deadLineChip.type = .green
      case .didNotProof:
        deadLineChip.type = .blue
    }
  }
  
  func configureSeperatorView(type: ModelType, isLast: Bool) {
    guard !isLast else {
      seperatorView.isHidden = true
      return
    }
    
    switch type {
      case .didNotProof:
        seperatorView.backgroundColor = .blue100
      case .proofURL, .proofImage:
        seperatorView.backgroundColor = .green0
    }
  }
}

extension Reactive where Base: ProofChallengeCell {
  var didTapImage: ControlEvent<Int> {
    let source = base.challengeImageView.rx.didTapImage
      .map { _ in base.challengeId }
    return .init(events: source)
  }
}
