//
//  ChallengeDeadLineView.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import DesignSystem

final class ChallengeDeadLineView: UIView, ChallengeInformationPresentable {
  // MARK: UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "종료 날짜".attributedString(
      font: .caption1Bold,
      color: .orange500
    )
    return label
  }()
  private let deadLineLabel = UILabel()
  
  var deadLine: String = "" {
    didSet { confiure(deadLine: deadLine) }
  }

  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Method
  func confiure(deadLine: String) {
    deadLineLabel.attributedText = "~ \(deadLine)".attributedString(
      font: .body2,
      color: .gray800
    ).setColor(.gray500, for: "~")
  }
}

// MARK: - UI Methods
private extension ChallengeDeadLineView {
  func setupUI() {
    configureBackground(color: .orange0, borderColor: .orange100)
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(titleLabel, deadLineLabel)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(14)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    deadLineLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(14)
    }
  }
}
