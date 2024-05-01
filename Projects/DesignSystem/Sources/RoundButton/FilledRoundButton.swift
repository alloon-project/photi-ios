//
//  FilledRoundButton.swift
//  DesignSystem
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Core

/// 내부가 색으로 채워진 Round Button입니다.
public final class FilledRoundButton: RoundButton {
  /// Round Button의 type입니다.
  public let type: RoundButtonType
  
  /// Round Button의 mode입니다.
  public var mode: RoundButtonMode {
    didSet {
      setupUI(type: type, mode: mode)
    }
  }
  
  // MARK: - Initalizers
  public init(
    text: String,
    type: RoundButtonType,
    size: RoundButtonSize,
    mode: RoundButtonMode = .default
  ) {
    self.type = type
    self.mode = mode
    super.init(size: size)
    self.setAttributedTitle(
      text.attributedString(font: font(for: size), color: .white),
      for: .normal
    )
    
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
  }
}

// MARK: - Private Methods
private extension FilledRoundButton {
  func setupUI(type: RoundButtonType, mode: RoundButtonMode) {
    self.backgroundColor = backGroundColor(type: self.type, mode: mode)
    
    if case .quaternary = type {
      self.setAttributedTitleColor(quaternaryTextColor(for: mode))
    }
  }
  
  func backGroundColor(type: RoundButtonType, mode: RoundButtonMode) -> UIColor {
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
  
  func primaryBackGroundColor(for mode: RoundButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .green400
      case .pressed:
        return .green600
      case .disabled:
        return .green200
    }
  }
  
  func secondaryBackGroundColor(for mode: RoundButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .pink400
      case .pressed:
        return .pink600
      case .disabled:
        return .pink200
    }
  }
  
  func teritiaryBackGroundColor(for mode: RoundButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .blue400
      case .pressed:
        return .blue600
      case .disabled:
        return .blue200
    }
  }
  
  func quaternaryBackGroundColor(for mode: RoundButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .gray100
      case .pressed, .disabled:
        return .gray200
    }
  }
  
  func quaternaryTextColor(for mode: RoundButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .gray600
      case .pressed:
        return .gray800
      case .disabled:
        return .gray500
    }
  }
}

public extension Reactive where Base: FilledRoundButton {
  var mode: Binder<RoundButtonMode> {
    return Binder(self.base) { button, value in
      button.mode = value
    }
  }
}
