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
  typealias ModelType = ProofChallengePresentationModel.ModelType
  
  // MARK: - Properties
  private(set) var isLast: Bool = false
  private(set) var model: ProofChallengePresentationModel?
  
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
  func configure(with model: ProofChallengePresentationModel, isLast: Bool) {
    self.model = model
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
      case .proof:
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
      case .proof:
        seperatorView.backgroundColor = .green0
    }
  }
}

extension Reactive where Base: ProofChallengeCell {
  var didTapImage: ControlEvent<Void> {
    return base.challengeImageView.rx.didTapImage
  }
}
