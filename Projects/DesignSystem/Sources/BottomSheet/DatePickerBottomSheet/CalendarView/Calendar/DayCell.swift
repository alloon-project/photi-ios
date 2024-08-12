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
      guard allowedSelection else { return }
      
      setCircleView(color: backgroundColor(for: dateType, isSelcted: isSelected))
      setLabel("\(day)", color: textColor(for: dateType, isSelected: isSelected))
    }
  }
  
  private(set) var allowedSelection: Bool = true
  private(set) var day: Int = 0
  private(set) var dateType: DateType = .default
  
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
  
  // MARK: - Configure Method
  func configure(
    dateType: DateType,
    day: Int,
    allowedSelection: Bool,
    isSelected: Bool = false
  ) {
    self.allowedSelection = allowedSelection
    self.dateType = dateType
    self.day = day
    
    switch dateType {
      case .default:
        self.isUserInteractionEnabled = true
      case .disabled, .startDate:
        self.isUserInteractionEnabled = false
    }
    
    setLabel("\(day)", color: textColor(for: dateType, isSelected: isSelected))
    setCircleView(color: backgroundColor(for: dateType, isSelcted: isSelected))
    
    self.isSelected = isSelected
  }
}

// MARK: - UI Methos
private extension DayCell {
  func setupUI() {
    self.circleView.layer.cornerRadius = 8

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
    if case .startDate = type {
      print(day)
    }
    switch type {
      case .default:
        return isSelected ? .photiWhite : .photiBlack
      case .disabled:
        return .gray300
      case .startDate:
        return .gray500
    }
  }
  
  func backgroundColor(for type: DateType, isSelcted: Bool) -> UIColor {
    switch type {
      case .default:
        return isSelcted ? .blue500 : .photiWhite
      case .disabled:
        return .photiWhite
      case .startDate:
        return .gray100
    }
  }
}
