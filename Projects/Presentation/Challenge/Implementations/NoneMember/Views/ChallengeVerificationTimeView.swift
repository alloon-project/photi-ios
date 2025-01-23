//
//  ChallengeVerificationTimeView.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class ChallengeVerificationTimeView: UIView, ChallengeInformationPresentable {
  // MARK: UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "인증 시간".attributedString(
      font: .caption1Bold,
      color: .gray700
    )
    return label
  }()
  private let timeLabel = UILabel()
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(time: String) {
    timeLabel.attributedText = time.attributedString(
      font: .body2Bold,
      color: .gray800
    )
  }
}

// MARK: - UI Methods
private extension ChallengeVerificationTimeView {
  func setupUI() {
    configureBackground(color: .gray0, borderColor: .gray100)
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(titleLabel, timeLabel)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(14)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    timeLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(14)
    }
  }
}
