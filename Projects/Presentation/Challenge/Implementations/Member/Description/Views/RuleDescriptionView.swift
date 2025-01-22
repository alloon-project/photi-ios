//
//  RuleDescriptionCell.swift
//  HomeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Core
import DesignSystem

final class RuleDescriptionView: UIView {
  private var rules = [String]() {
    didSet {
      self.rulesLabels = configureRuleLabels(rules)
    }
  }
  
  // MARK: - UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "인증 룰".attributedString(
      font: .body1Bold,
      color: .gray900
    )
    return label
  }()
  private let ruleStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    stackView.spacing = 16
    
    return stackView
  }()
  private let challengeVerificationTimeView: UIView = {
    let view = UIView()
    view.backgroundColor = .blue0
    view.layer.cornerRadius = 8
    
    return view
  }()
  private let challengeVerificationImageView = UIImageView(image: .timeBlue)
  private let challengeVerificationTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "인증 시간".attributedString(
      font: .body2Bold,
      color: .blue500
    )
    return label
  }()

  private let challengeVerificationTimeLabel = UILabel()
  
  private var rulesLabels: [UILabel] = [] {
    didSet {
      oldValue.forEach { $0.removeFromSuperview() }
      ruleStackView.addArrangedSubviews(rulesLabels)
    }
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
  
  // MARK: - Configure Methods
  func configure(rules: [String], vertificationTime: String) {
    self.rules = rules
    challengeVerificationTimeLabel.attributedText = vertificationTime.attributedString(
      font: .body2,
      color: .blue400
    )
  }
}

// MARK: - UI Methods
private extension RuleDescriptionView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(
      titleLabel,
      ruleStackView,
      challengeVerificationTimeView
    )
    challengeVerificationTimeView.addSubviews(
      challengeVerificationImageView,
      challengeVerificationTitleLabel,
      challengeVerificationTimeLabel
    )
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
    }
    
    ruleStackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(20)
    }
    
    challengeVerificationTimeView.snp.makeConstraints {
      $0.top.equalTo(ruleStackView.snp.bottom).offset(20)
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(42)
    }
    
    challengeVerificationImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(14)
      $0.width.height.equalTo(24)
      $0.centerY.equalToSuperview()
    }
    
    challengeVerificationTitleLabel.snp.makeConstraints {
      $0.leading.equalTo(challengeVerificationImageView.snp.trailing).offset(4)
      $0.centerY.equalToSuperview()
    }
    
    challengeVerificationTimeLabel.snp.makeConstraints {
      $0.leading.equalTo(challengeVerificationTitleLabel.snp.trailing).offset(10)
      $0.centerY.equalToSuperview()
    }
  }
}

// MARK: - Private Methods
private extension RuleDescriptionView {
  func configureRuleLabels(_ rules: [String]) -> [UILabel] {
    rules.map {
      let label = UILabel()
      label.attributedText = $0.attributedString(
        font: .body2,
        color: .gray600
      )
      return label
    }
  }
}
