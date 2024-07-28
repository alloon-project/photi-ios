//
//  TimePickerViewCell.swift
//  DesignSystem
//
//  Created by jung on 7/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class TimePickerViewCell: UIView {
  let hourText: String
  let minuteText: String
  
  // MARK: - UI Components
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 16
    stackView.distribution = .fillProportionally
    stackView.alignment = .center
    
    return stackView
  }()
  
  private let hourLabel = UILabel()
  private let minuteLabel = UILabel()
  private let seperatorLabel: UILabel = {
    let label = UILabel()
    label.attributedText = ":".attributedString(font: .body1Bold, color: .gray900)

    return label
  }()
  
  // MARK: - Initializers
  init(hour: Int, minute: Int) {
    let hour = "\(hour)"
    let minute = "\(minute)"
    
    self.hourText = hour.count == 1 ? "0\(hour)" : hour
    self.minuteText = minute.count == 1 ? "0\(minute)" : minute
    
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension TimePickerViewCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    setHourAndMinuteText(hourText, minuteText, with: .gray900)
  }
  
  func setViewHierarchy() {
    self.addSubviews(stackView)
    stackView.addArrangedSubviews(hourLabel, seperatorLabel, minuteLabel)
  }
  
  func setConstraints() {
    stackView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.top.bottom.equalToSuperview().inset(24)
    }
  }
}

// MARK: - Private Methods
private extension TimePickerViewCell {
  func setHourAndMinuteText(_ hour: String, _ minute: String, with color: UIColor) {
    hourLabel.attributedText = hour.attributedString(font: .body1Bold, color: color)
    minuteLabel.attributedText = minute.attributedString(font: .body1Bold, color: color)
  }
}
