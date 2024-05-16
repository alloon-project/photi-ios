//
//  DayCell.swift
//  DesignSystem
//
//  Created by jung on 5/13/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class DayCell: UICollectionViewCell {
  override var isSelected: Bool {
    didSet {
      setCircleView(color: backgroundColor(for: type, isSelcted: isSelected))
      setLabel("\(day)", color: textColor(for: type, isSelected: isSelected))
    }
  }
  
  private(set) var day: Int = 0
  private(set) var type: DateType = .default
  
  // MARK: - UI Components
  private let circleView = UIView()
  private let label = UILabel()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    circleView.layer.cornerRadius = self.frame.height / 2
  }
  
  // MARK: - Configure Method
  func configure(
    type: DateType,
    day: Int,
    isSelected: Bool = false
  ) {
    self.type = type
    self.day = day
    
    switch type {
      case .default:
        self.isUserInteractionEnabled = true
      case .disabled, .startDate:
        self.isUserInteractionEnabled = false
    }
    
    setLabel("\(day)", color: textColor(for: type, isSelected: isSelected))
    setCircleView(color: backgroundColor(for: type, isSelcted: isSelected))

    self.isSelected = isSelected
  }
}

// MARK: - UI Methos
private extension DayCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubview(circleView)
    circleView.addSubview(label)
  }
  
  func setConstraints() {
    label.snp.makeConstraints { $0.center.equalToSuperview() }
    circleView.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}

// MARK: - Private Methods
private extension DayCell {
  func setLabel(_ text: String, color: UIColor) {
    label.attributedText = text.attributedString(
      font: .body1Bold,
      color: color,
      alignment: .center
    )
  }
  
  func setCircleView(color: UIColor) {
    self.circleView.backgroundColor = color
  }
  
  func textColor(for type: DateType, isSelected: Bool) -> UIColor {
    switch type {
      case .default:
        return isSelected ? .alloonWhite : .alloonBlack
      case .disabled:
        return .gray300
      case .startDate:
        return .alloonWhite
    }
  }
  
  func backgroundColor(for type: DateType, isSelcted: Bool) -> UIColor {
    switch type {
      case .default:
        return isSelcted ? .green500 : .alloonWhite
      case .disabled:
        return .alloonWhite
      case .startDate:
        return .gray500
    }
  }
}
