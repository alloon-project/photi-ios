//
//  FloatingButton.swift
//  DesignSystem
//
//  Created by jung on 5/1/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

/// 화면에 floating 되어 있는 버튼입니다. 
public final class FloatingButton: UIButton {
  /// Floating Button의 size입니다.
  public let size: ButtonSize
  
  /// Floating Button의 type입니다.
  public let type: FloatingButtonType
  
  /// Floating Button의 mode입니다.
  public private(set) var mode: ButtonMode {
    didSet {
      self.backgroundColor = backgroundColor(type: type, mode: mode)
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
    self.cgSize(for: size)
  }
  
  // MARK: - Initializers
  public init(
    type: FloatingButtonType,
    size: ButtonSize,
    mode: ButtonMode = .default
  ) {
    self.type = type
    self.size = size
    self.mode = mode
    super.init(frame: .zero)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.bounds.size.width / 2
  }
  
  // MARK: - Point
  public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let circlePath = UIBezierPath(ovalIn: self.bounds)

    return circlePath.contains(point)
  }
}

// MARK: - Private Methods
private extension FloatingButton {
  func setupUI() {
    self.backgroundColor = backgroundColor(type: type, mode: mode)
    
    switch type {
      case .primary:
        primarySetupUI()
      case .secondary:
        secondarySetupUI()
    }
  }
  
  func primarySetupUI() {
    let image = UIImage.plusWhite.resize(imageSize(for: size))
    setImage(image, for: .normal)
    setImage(image, for: .highlighted)
    setImage(image, for: .disabled)
  }
  
  func secondarySetupUI() {
    let defaultImage = UIImage.plusGray700.resize(imageSize(for: size))
    let disabledImage = UIImage.plusGray400.resize(imageSize(for: size))
    
    setImage(defaultImage, for: .normal)
    setImage(defaultImage, for: .highlighted)
    setImage(disabledImage, for: .disabled)
      
    self.drawShadow(
      color: UIColor(red: 0.118, green: 0.137, blue: 0.149, alpha: 0.1),
      opacity: 1,
      radius: 10
    )
  }
  
  func backgroundColor(type: FloatingButtonType, mode: ButtonMode) -> UIColor {
    switch type {
      case .primary:
        return primaryBackgroundColor(for: mode)
      case .secondary:
        return secondaryBackgroundColor(for: mode)
    }
  }
  
  func primaryBackgroundColor(for mode: ButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .blue500
      case .pressed:
        return .blue600
      case.disabled:
        return .blue200
    }
  }
  
  func secondaryBackgroundColor(for mode: ButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .gray100
      case .pressed, .disabled:
        return .gray200
    }
  }
  
  func cgSize(for size: ButtonSize) -> CGSize {
    switch size {
      case .xLarge:
        return CGSize(width: 56, height: 56)
      case .large:
        return CGSize(width: 48, height: 48)
      case .medium:
        return CGSize(width: 40, height: 40)
      case .small:
        return CGSize(width: 32, height: 32)
      case .xSmall:
        return CGSize(width: 24, height: 24)
    }
  }
  
  func imageSize(for size: ButtonSize) -> CGSize {
    switch size {
      case .xLarge, .large:
        return CGSize(width: 24, height: 24)
      case .medium:
        return CGSize(width: 20, height: 20)
      case .small, .xSmall:
        return CGSize(width: 16, height: 16)
    }
  }
}
