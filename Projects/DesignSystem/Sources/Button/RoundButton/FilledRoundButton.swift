//
//  FilledRoundButton.swift
//  DesignSystem
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

/// 내부가 색으로 채워진 Round Button입니다.
public final class FilledRoundButton: RoundButton {
  /// Round Button의 type입니다.
  public let type: RoundButtonType
  
  /// Round Button의 mode입니다.
  public var mode: ButtonMode {
    didSet {
      setupUI(type: type, mode: mode)
    }
  }
  
  public override var isHighlighted: Bool {
    didSet {
      self.mode = isHighlighted ? .pressed : .default
    }
  }
  
  public override var isEnabled: Bool {
    didSet {
      self.mode = isEnabled ? .default : .disabled
    }
  }
  
  // MARK: - Initalizers
  public init(
    type: RoundButtonType,
    size: ButtonSize,
    text: String = "",
    mode: ButtonMode = .default
  ) {
    self.type = type
    self.mode = mode
    super.init(size: size)
    
    self.setText(text, for: .normal)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup UI
  public override func setupUI() {
    super.setupUI()
    
    self.setupUI(type: type, mode: mode)
    
    if case .quaternary = type {
      quaternarySetupUI()
    }
  }
}

// MARK: - Public Methods
public extension FilledRoundButton {
  func setText(_ text: String, for state: UIControl.State) {
    self.setAttributedTitle(
      text.attributedString(font: font(for: size), color: .white),
      for: state
    )
  }
}

// MARK: - Private Methods
private extension FilledRoundButton {
  func setupUI(type: RoundButtonType, mode: ButtonMode) {
    self.backgroundColor = backGroundColor(type: self.type, mode: mode)
  }
  
  func quaternarySetupUI() {
    guard let attributedTitle = self.attributedTitle(for: .normal) else { return }
    
    setAttributedTitle(attributedTitle.setColor(.gray600), for: .normal)
    setAttributedTitle(attributedTitle.setColor(.gray800), for: .highlighted)
    setAttributedTitle(attributedTitle.setColor(.gray500), for: .disabled)
  }
  
  func backGroundColor(type: RoundButtonType, mode: ButtonMode) -> UIColor {
    switch type {
      case .primary:
        return primaryBackGroundColor(for: mode)
      case .secondary:
        return secondaryBackGroundColor(for: mode)
      case .tertiary:
        return teritiaryBackGroundColor(for: mode)
      case .quaternary:
        return quaternaryBackGroundColor(for: mode)
    }
  }
  
  func primaryBackGroundColor(for mode: ButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .blue400
      case .pressed:
        return .blue600
      case .disabled:
        return .blue200
    }
  }
  
  func secondaryBackGroundColor(for mode: ButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .green400
      case .pressed:
        return .green500
      case .disabled:
        return .green200
    }
  }
  
  func teritiaryBackGroundColor(for mode: ButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .orange400
      case .pressed:
        return .orange600
      case .disabled:
        return .orange200
    }
  }
  
  func quaternaryBackGroundColor(for mode: ButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .gray100
      case .pressed, .disabled:
        return .gray200
    }
  }
}
