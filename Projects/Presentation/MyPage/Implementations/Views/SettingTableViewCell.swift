//
//  SettingNaviagationTableViewCell.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import DesignSystem

final class SettingTableViewCell: UITableViewCell {
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let arrowImageView = UIImageView()
  private let rightLabel = UILabel()
  
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
  func configure(
    with text: String,
    type: SettingTableViewCellType,
    font: UIFont = .body2,
    rightTextColor: UIColor = .gray900
  ) {
    titleLabel.attributedText = text.attributedString(
      font: .body1,
      color: .gray900
    )
    
    switch type {
      case .default:
      arrowImageView.image = arrowImage
      arrowImageView.isHidden = false
      rightLabel.isHidden = true
    case .label(let text):
      rightLabel.attributedText = text.attributedString(font: font, color: rightTextColor)
      arrowImageView.isHidden = true
      rightLabel.isHidden = false
    }
  }
}

// MARK: UI Methods
private extension SettingTableViewCell {
  func setupUI() {
    self.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(
      titleLabel,
      arrowImageView,
      rightLabel
    )
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.centerY.equalToSuperview()
    }
    
    arrowImageView.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-24)
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(13)
    }
    
    rightLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-24)
    }
  }
}
