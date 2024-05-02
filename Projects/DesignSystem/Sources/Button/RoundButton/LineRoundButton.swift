//
//  LineRoundButton.swift
//  DesignSystem
//
//  Created by jung on 5/1/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

/// border가 색칠된 line으로 구성된 Round Button입니다.
public final class LineRoundButton: RoundButton {
  /// Round Button의 type입니다.
  public let type: RoundButtonType
  
  // MARK: - Initalizers
  public init(
    text: String,
    type: RoundButtonType,
    size: ButtonSize
  ) {
    self.type = type
    super.init(size: size)
    setupUI()
    
    self.setAttributedTitle(
      text.attributedString(font: font(for: size), color: textColor(for: type)),
      for: .normal
    )
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup UI
  public override func setupUI() {
    super.setupUI()
    
    self.backgroundColor = .clear
    self.layer.borderWidth = 1
    self.layer.borderColor = lineColor(for: type).cgColor
  }
}

// MARK: - Private Methods
private extension LineRoundButton {
  func lineColor(for type: RoundButtonType) -> UIColor {
    switch type {
      case .primary:
        return .green400
      case .secondary:
        return .pink200
      case.tertiary:
        return .blue200
      case .quaternary:
        return .gray200
    }
  }
  
  func textColor(for type: RoundButtonType) -> UIColor {
    switch type {
      case .primary:
        return .green500
      case .secondary:
        return .pink500
      case .tertiary:
        return .blue500
      case .quaternary:
        return .gray600
    }
  }
}
