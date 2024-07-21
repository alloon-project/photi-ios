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
    
    var config = UIButton.Configuration.plain()
    config.contentInsets = contentInset(for: size)
    configuration = config
  }
}

// MARK: - Private Extension
private extension TextButton {
  func primarySetupUI(_ isEnabledUnderLine: Bool) {
    var textAttributes = text
      .attributedString(font: font(for: size), color: .blue400)
    
    textAttributes = isEnabledUnderLine ? textAttributes.setUnderLine() : textAttributes
    
    setAttributedTitle(textAttributes, for: .normal)
    setAttributedTitle(textAttributes.setColor(.blue500), for: .highlighted)
    setAttributedTitle(textAttributes.setColor(.gray500), for: .disabled)
  }
  
  func secondarySetupUI(_ isEnabledUnderLine: Bool) {
    var textAttributes = text
      .attributedString(font: font(for: size), color: .gray0)

    textAttributes = isEnabledUnderLine ? textAttributes.setUnderLine() : textAttributes
    
    setAttributedTitle(textAttributes, for: .normal)
    setAttributedTitle(textAttributes.setColor(.photiWhite), for: .highlighted)
    setAttributedTitle(textAttributes.setColor(.gray300), for: .disabled)
  }
  
  func graySetupUI(_ isEnabledUnderLine: Bool) {
    var textAttributes = text
      .attributedString(font: font(for: size), color: .gray600)
    
    textAttributes = isEnabledUnderLine ? textAttributes.setUnderLine() : textAttributes

    setAttributedTitle(textAttributes, for: .normal)
    setAttributedTitle(textAttributes.setColor(.gray700), for: .highlighted)
    setAttributedTitle(textAttributes.setColor(.gray400), for: .disabled)
  }
  
  func contentInset(for size: ButtonSize) -> NSDirectionalEdgeInsets {
    switch size {
      case .xLarge, .large:
        return NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
      case .medium, .small:
        return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
      case .xSmall:
        return NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
    }
  }
  
  func font(for size: ButtonSize) -> UIFont {
    switch size {
      case .xLarge:
        return .heading3Medium
      case .large:
        return .heading4Medium
      case .medium:
        return .body1
      case .small:
        return .body2
      case .xSmall:
        return .caption1
    }
  }
}
