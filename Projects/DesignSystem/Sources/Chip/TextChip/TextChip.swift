//
//  TextChip.swift
//  DesignSystem
//
//  Created by jung on 5/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

/// Text의 길이에 따라 유동적이로 길이가 변하는 View입니다.
public final class TextChip: UIView {
  /// Text Chip의 size입니다.
  public let size: ChipSize
  
  /// Text Chip의 type입니다.
  public let type: TextChipType
  
  /// Chip의 text입니다.
  public var text: String {
    didSet {
      setLabel(text)
    }
  }

  // MARK: - UI Components
  private let label = UILabel()

  // MARK: - Initializers
  public init(
    text: String,
    type: TextChipType,
    size: ChipSize
  ) {
    self.text = text
    self.type = type
    self.size = size
    super.init(frame: .zero)
    
    setupUI()
  }
  
  public convenience init(type: TextChipType, size: ChipSize) {
    self.init(text: "", type: type, size: size)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.frame.height / 2
  }
}

// MARK: - UI Methods
private extension TextChip {
  func setupUI() {
    self.backgroundColor = backgoundColor(for: type)
    
    setViewHierarchy()
    setConstraints(for: size)
    setBorderLine(for: type)
    setLabel(text)
  }
  
  func setViewHierarchy() {
    self.addSubview(label)
  }
  
  func setConstraints(for size: ChipSize) {
    switch size {
      case .large:
        label.snp.makeConstraints {
          $0.top.bottom.equalToSuperview().inset(10)
          $0.leading.trailing.equalToSuperview().inset(12)
        }
      case .medium, .small:
        label.snp.makeConstraints {
          $0.edges.equalToSuperview().inset(8)
        }
    }
  }
  
  func setBorderLine(for type: TextChipType) {
    switch type {
      case .line:
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray300.cgColor
      case .pink:
        layer.borderWidth = 1
        layer.borderColor = UIColor.pink300.cgColor
      default: break
    }
  }
  
  func setLabel(_ text: String) {
    label.attributedText = text.attributedString(
      font: font(for: size),
      color: textColor(for: type)
    )
  }
}

// MARK: - Private Methods
private extension TextChip {
  func backgoundColor(for type: TextChipType) -> UIColor {
    switch type {
      case .white:
        return UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
      case .line:
        return .alloonWhite
      case .gray:
        return .gray0
      case .darkGray:
        return .gray200
      case .pink:
        return .pink0
    }
  }
  
  func textColor(for type: TextChipType) -> UIColor {
    switch type {
      case .white:
        return .alloonWhite
      case .line:
        return .gray800
      case .gray, .darkGray:
        return .gray600
      case .pink:
        return .pink400
    }
  }
  
  func font(for size: ChipSize) -> UIFont {
    switch size {
      case .large:
        return .body2
      case .medium:
        return .caption1
      case .small:
        return .caption2
    }
  }
}