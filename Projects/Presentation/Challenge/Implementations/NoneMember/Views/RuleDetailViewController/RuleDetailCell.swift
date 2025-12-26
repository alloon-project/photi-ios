//
//  RuleDetailCell.swift
//  HomeImpl
//
//  Created by jung on 1/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import CoreUI
import DesignSystem

final class RuleDetailCell: UITableViewCell {
  // MARK: - UI Components
  private let leftLineView: UIView = {
    let view = UIView()
    view.backgroundColor = .green200
    view.layer.cornerRadius = 1
    
    return view
  }()
  private let mainContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .green100
    
    return view
  }()
  private let ruleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    
    return label
  }()
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(rule: String) {
    ruleLabel.attributedText = rule.attributedString(
      font: .body2,
      color: .gray800
    )
  }
}

// MARK: - UI Methods
private extension RuleDetailCell {
  func setupUI() {
    backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(leftLineView, mainContentView)
    mainContentView.addSubview(ruleLabel)
  }
  
  func setConstraints() {
    leftLineView.snp.makeConstraints {
      $0.top.bottom.leading.equalToSuperview()
      $0.width.equalTo(2)
    }
    
    mainContentView.snp.makeConstraints {
      $0.top.bottom.equalTo(leftLineView).inset(1)
      $0.leading.equalToSuperview().offset(1)
      $0.trailing.equalToSuperview()
    }
    
    ruleLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(14)
      $0.centerY.equalToSuperview()
    }
  }
}
