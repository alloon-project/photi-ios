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

class ReportReasonTableViewCell: UITableViewCell {
  private var textColor: UIColor {
    isSelected ? .black : .gray600
  }

  override var isSelected: Bool {
    didSet {
      setCheckImage(isSelected: isSelected)
      setLabelTextColor(isSelected: isSelected)
    }
  }
  // MARK: - UI Components
  private let selectImageView = UIImageView(image: UIImage(systemName: "checkmark.circle")?.withTintColor(.gray300))
  private let reportContentLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    return label
  }()
  
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
  func configure(with text: String, isSelected: Bool) {
    self.isSelected = isSelected
    reportContentLabel.attributedText = text.attributedString(
      font: .body2,
      color: .gray900
    )
  }
}

private extension ReportReasonTableViewCell {
  func setupUI() {
    self.backgroundColor = .clear
    setViewHierarchy()
    setConstraints()
  }
  func setViewHierarchy() {
    contentView.addSubviews(selectImageView, reportContentLabel)
  }
  func setConstraints() {
    selectImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(4)
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(24)
    }
    reportContentLabel.snp.makeConstraints {
      $0.leading.equalTo(selectImageView.snp.trailing).offset(6)
      $0.trailing.equalToSuperview().offset(-12)
      $0.centerY.equalToSuperview()
    }
  }
}

// MARK: - Private methods
private extension ReportReasonTableViewCell {
  func setCheckImage(isSelected: Bool) {
    if isSelected {
      selectImageView.image = UIImage(systemName: "checkmark.circle.fill")?
                              .withTintColor(.green400, renderingMode: .alwaysOriginal)
    } else {
      selectImageView.image = UIImage(systemName: "checkmark.circle")?
                              .withTintColor(.gray300, renderingMode: .alwaysOriginal)
    }
  }
  
  func setLabelTextColor(isSelected: Bool) {
    reportContentLabel.attributedText = reportContentLabel.attributedText?.setColor(textColor)
  }
}
