//
//  CreateChallengeInformationView.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class CreateChallengeInformationView: UIView {
  // MARK: - UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "더 많은 챌린지는\n어디서 만날 수 있을까요?".attributedString(
      font: .body1Bold,
      color: .gray900
    )
    label.textAlignment = .center
    label.numberOfLines = 0
    
    return label
  }()
  
  private let leftContentView = CreateChallengeContentView(
    text: "‘챌린지' 탭으로 이동해\n다양한 챌린지를 만나보세요.",
    image: .homeMemberSignboard
  )
  private let rightContentView = CreateChallengeContentView(
    text: "새로운 열정을\n만들어 보세요.",
    image: .homeMemberFire
  )
  
  fileprivate let createChallengeButton = LineRoundButton(text: "챌린지 만들기", type: .primary, size: .small)
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension CreateChallengeInformationView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(titleLabel, leftContentView, rightContentView, createChallengeButton)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.centerX.equalToSuperview()
    }
    
    leftContentView.snp.makeConstraints {
      $0.leading.bottom.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(21)
      $0.trailing.equalTo(rightContentView.snp.leading).offset(-10)
    }
    
    rightContentView.snp.makeConstraints {
      $0.width.equalTo(createChallengeButton)
      $0.trailing.equalToSuperview()
      $0.top.equalTo(leftContentView)
    }
    
    createChallengeButton.snp.makeConstraints {
      $0.leading.equalTo(rightContentView)
      $0.top.equalTo(rightContentView.snp.bottom).offset(10)
      $0.bottom.equalToSuperview()
    }
  }
}

extension Reactive where Base: CreateChallengeInformationView {
  var didTapCreateButton: ControlEvent<Void> {
    return base.createChallengeButton.rx.tap
  }
}
