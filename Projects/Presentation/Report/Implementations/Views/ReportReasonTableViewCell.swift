//
//  ReportReasonTableViewCell.swift
//  HomeImpl
//
//  Created by wooseob on 6/28/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

class ReportReasonTableViewCell: UITableViewCell {
  private var textColor: UIColor {
    isSelected ? .photiBlack : .gray600
  }
  
  private var iconImage: UIImage {
    isSelected ? .checkmarkSelectedBlue : .checkmarkGray400
  }

  override var isSelected: Bool {
    didSet {
      setCheckImage(isSelected: isSelected)
      setLabelTextColor(isSelected: isSelected)
    }
  }
  // MARK: - UI Components
  private let iconImageView = UIImageView()
  private let reportContentLabel = UILabel()
  
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
  func configure(with text: String, isSelected: Bool = false) {
    self.isSelected = isSelected
    reportContentLabel.attributedText = text.attributedString(
      font: .body2,
      color: .gray900
    )
  }
}

// MARK: UI Methods
private extension ReportReasonTableViewCell {
  func setupUI() {
    self.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(iconImageView, reportContentLabel)
  }
  
  func setConstraints() {
    iconImageView.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview().inset(4)
      $0.width.height.equalTo(24)
    }
    reportContentLabel.snp.makeConstraints {
      $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
      $0.trailing.equalToSuperview().offset(-12)
      $0.centerY.equalToSuperview()
    }
  }
}

// MARK: - Private methods
private extension ReportReasonTableViewCell {
  func setCheckImage(isSelected: Bool) {
    iconImageView.image = iconImage
  }
  
  func setLabelTextColor(isSelected: Bool) {
    reportContentLabel.attributedText = reportContentLabel.attributedText?.setColor(textColor)
  }
}
