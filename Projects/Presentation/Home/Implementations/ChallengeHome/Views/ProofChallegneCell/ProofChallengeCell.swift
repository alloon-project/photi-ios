//
//  ProofChallengeCell.swift
//  HomeImpl
//
//  Created by jung on 10/7/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Combine
import DesignSystem
import CoreUI

final class ProofChallengeCell: UICollectionViewCell {
  typealias ModelType = MyChallengeFeedPresentationModel.ModelType

  // MARK: - Properties
  private(set) var isLast: Bool = false
  private(set) var challengeId: Int = 0
  private var cancellables = Set<AnyCancellable>()

  var didTapCameraButton: AnyPublisher<Int, Never> {
    challengeImageView.didTapImage
      .filter { [weak self] _ in self?.type == .didNotProof }
      .map { [weak self] _ in self?.challengeId ?? 0 }
      .eraseToAnyPublisher()
  }

  var didTapFeed: AnyPublisher<(challengeId: Int, feedId: Int), Never> {
    challengeImageView.didTapImage
      .filter { [weak self] _ in self?.type != .didNotProof }
      .map { [weak self] _ in (challengeId: self?.challengeId ?? 0, feedId: self?.feedId ?? -1) }
      .eraseToAnyPublisher()
  }

  // MARK: - UI Components
  private let deadLineChip = TextChip(type: .green, size: .large)
  private let titleView = ChallengeTitleView()
  private let seperatorView = UIView()
  private var type: ModelType = .didNotProof
  private var feedId: Int = -1
  private let challengeImageView = ChallengeImageView()
  
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
    self.challengeId = model.challengeId
    self.type = model.type

    if case let .didProof(_, feedId) = type {
      self.feedId = feedId
    }
    
    configureDeadLineChip(model.deadLine)
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
      $0.height.equalTo(2)
      $0.centerY.equalTo(deadLineChip)
    }
    
    titleView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(deadLineChip.snp.bottom).offset(16)
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
private extension ProofChallengeCell {
  func setupUI(type: ModelType, isLast: Bool) {
    configureSeperatorView(type: type, isLast: isLast)
    
    switch type {
      case .didProof:
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
      case .didProof:
        seperatorView.backgroundColor = .green0
    }
  }
  
  func configureDeadLineChip(_ deadLine: String) {
    switch type {
      case .didNotProof:
        deadLineChip.text = deadLine
      case .didProof:
        deadLineChip.text = "인증완료!"
    }
  }
}

