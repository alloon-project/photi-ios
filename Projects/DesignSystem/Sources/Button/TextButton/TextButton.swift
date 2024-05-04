//
//  TextButton.swift
//  DesignSystem
//
//  Created by jung on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

/// 텍스트와 underline으로 구성된 버튼입니다.
public final class TextButton: UIButton {
  /// Text Button의 size입니다.
  public let size: ButtonSize
  
  /// Text Button의 type입니다.
  public let type: TextButtonType
  
  /// Text Button의 mode입니다.
  public private(set) var mode: ButtonMode
  
  /// Text Button의 text입니다.
  public var text: String {
    didSet {
      setupUI()
    }
  }
  
  /// Text Button의 underline을 활성화 할지 결정합니다. default는 `false`입니다.
  public var isEnabledUnderLine: Bool {
    didSet {
      setupUI()
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
  
  public override var intrinsicContentSize: CGSize {
    cgSize(for: size)
  }
  
  // MARK: - Initializers
  public init(
    text: String,
    size: ButtonSize,
    type: TextButtonType,
    mode: ButtonMode = .default,
    isEnabledUnderLine: Bool = false
  ) {
    self.text = text
    self.size = size
    self.type = type
    self.mode = mode
    self.isEnabledUnderLine = isEnabledUnderLine
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup UI
  func setupUI() {
    switch type {
      case .primary:
        primarySetupUI(isEnabledUnderLine)
      case .secondary:
        secondarySetupUI(isEnabledUnderLine)
      case .gray:
        graySetupUI(isEnabledUnderLine)
    }
  }
}

// MARK: - Private Extension
private extension TextButton {
  func primarySetupUI(_ isEnabledUnderLine: Bool) {
    var textAttributes = text
      .attributedString(font: font(for: size), color: .green400)
    
    textAttributes = isEnabledUnderLine ? textAttributes.setUnderLine() : textAttributes
    
    setAttributedTitle(textAttributes, for: .normal)
    setAttributedTitle(textAttributes.setColor(.green500), for: .highlighted)
    setAttributedTitle(textAttributes.setColor(.gray500), for: .disabled)
  }
  
  func secondarySetupUI(_ isEnabledUnderLine: Bool) {
    var textAttributes = text
      .attributedString(font: font(for: size), color: .gray0)

    textAttributes = isEnabledUnderLine ? textAttributes.setUnderLine() : textAttributes
    
    setAttributedTitle(textAttributes, for: .normal)
    setAttributedTitle(textAttributes.setColor(.alloonWhite), for: .highlighted)
  }
  
  func graySetupUI(_ isEnabledUnderLine: Bool) {
    var textAttributes = text
      .attributedString(font: font(for: size), color: .gray600)
    
    textAttributes = isEnabledUnderLine ? textAttributes.setUnderLine() : textAttributes

    setAttributedTitle(textAttributes, for: .normal)
    setAttributedTitle(textAttributes.setColor(.gray700), for: .highlighted)
    setAttributedTitle(textAttributes.setColor(.gray400), for: .disabled)
  }
  
  func cgSize(for size: ButtonSize) -> CGSize {
    switch size {
      case .xLarge:
        return CGSize(width: 59, height: 38)
      case .large:
        return CGSize(width: 56, height: 37)
      case .medium:
        return CGSize(width: 48, height: 32)
      case .small:
        return CGSize(width: 45, height: 30)
      case .xSmall:
        return CGSize(width: 37, height: 25)
    }
  }
  
  func font(for size: ButtonSize) -> UIFont {
    switch size {
      case .xLarge:
        return .heading3
      case .large:
        return .heading4
      case .medium:
        return .body1
      case .small:
        return .body2
      case .xSmall:
        return .caption1
    }
  }
}
