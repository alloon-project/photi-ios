//
//  SettingVersionTableViewCell.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

final class SettingVersionTableViewCell: UITableViewCell {
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let versionLabel = UILabel()
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(leftText: String,
                 leftTextColor: UIColor = .gray900,
                 rightText: String,
                 rightTextColor: UIColor = .gray500) {
    titleLabel.attributedText = leftText.attributedString(
      font: .body1,
      color: leftTextColor
    )
    versionLabel.attributedText = rightText.attributedString(
      font: .body1,
      color: rightTextColor
    )
  }
}

// MARK: UI Methods
private extension SettingVersionTableViewCell {
  func setupUI() {
    self.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(titleLabel, versionLabel)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.centerY.equalToSuperview()
    }
    versionLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-24)
      $0.centerY.equalToSuperview()
    }
  }
}