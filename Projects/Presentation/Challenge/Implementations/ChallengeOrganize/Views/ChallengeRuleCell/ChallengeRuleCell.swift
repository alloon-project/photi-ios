//
//  ChallengeRuleCell.swift
//  Presentation
//
//  Created by 임우섭 on 4/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import DesignSystem

final class ChallengeRuleCell: UICollectionViewCell {
  // MARK: - UI Components
  private let stackView: UIStackView = {
    let view = UIStackView()
    view.axis = .horizontal
    view.spacing = 6
    view.distribution = .fill

    return view
  }()
  
  private let challengeRuleLabel = {
    let label = UILabel()
    label.numberOfLines = 3
    label.attributedText = "일주일 3회 이상 인증하기".attributedString(
      font: .caption1,
      color: .gray600
    )
    
    return label
  }()
  
  // TODO: - 아이콘이 안보이는 문제 있음
  private let deleteButton = {
    let button = IconButton(
      selectedIcon: .closeCircleBlue,
      unSelectedIcon: .closeCircleGray400,
      size: .xSmall
    )
    
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
  func configure(
    with rule: String,
    isSelected: Bool,
    isDefault: Bool
  ) {
    challengeRuleLabel.attributedText = rule.attributedString(
      font: .caption1,
      color: isSelected ? .blue500 : .gray600
    )
    challengeRuleLabel.textAlignment = .center
    self.contentView.backgroundColor = isSelected ? .blue0 : .white
    self.layer.borderColor = isSelected ? UIColor.blue400.cgColor : UIColor.gray200.cgColor

    deleteButton.isHidden = (rule == "+" || isDefault)
  }
}

// MARK: - UI Methods
private extension ChallengeRuleCell {
  func setupUI() {
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.gray200.cgColor
    self.layer.cornerRadius = 12
    self.contentView.clipsToBounds = true
    self.contentView.layer.cornerRadius = 12
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(stackView)
    
    stackView.addArrangedSubviews(challengeRuleLabel, deleteButton)
  }
  
  func setConstraints() {
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    challengeRuleLabel.snp.makeConstraints {
      $0.height.equalToSuperview()
    }
    
    deleteButton.snp.makeConstraints {
      $0.height.width.equalTo(24)
    }
  }
}
