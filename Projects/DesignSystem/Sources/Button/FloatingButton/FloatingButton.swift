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
  
  /// Round Button의 mode입니다.
  public private(set) var mode: ButtonMode {
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
  
  public override var intrinsicContentSize: CGSize {
    self.cgSize(for: size)
  }
  
  // MARK: - Initializers
  public init(
    type: FloatingButtonType,
    size: ButtonSize,
    image: UIImage = UIImage(systemName: "plus")!,
    mode: ButtonMode = .default
  ) {
    self.type = type
    self.size = size
    self.mode = mode
    super.init(frame: .zero)
    
    setupUI(image)
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
  
  // MARK: - Setup UI
  func setupUI(_ image: UIImage) {
    let resizeImage = image.resize(imageSize(for: size))
    
    switch type {
      case .primary:
        primarySetupUI(resizeImage)
      case .secondary:
        secondarySetupUI(resizeImage)
    }

    self.setupUI(type: type, mode: mode)
  }
}

// MARK: - Private Methods
private extension FloatingButton {
  func setupUI(type: FloatingButtonType, mode: ButtonMode) {
    self.backgroundColor = backgroundColor(type: type, mode: mode)
  }
  
  func primarySetupUI(_ image: UIImage) {
    let image = image.withTintColor(.alloonWhite)
    setImage(image, for: .normal)
    setImage(image, for: .highlighted)
    setImage(image, for: .disabled)
  }
  
  func secondarySetupUI(_ image: UIImage) {
    setImage(image.withTintColor(.gray600), for: .normal)
    setImage(image.withTintColor(.gray800), for: .highlighted)
    setImage(image.withTintColor(.gray500), for: .disabled)
      
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
        return .green500
      case .pressed:
        return .green600
      case.disabled:
        return .green200
    }
  }
  
  func secondaryBackgroundColor(for mode: ButtonMode) -> UIColor {
    switch mode {
      case .default:
        return .gray100
      case .pressed:
        return .gray200
      case.disabled:
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
      case .xLarge:
        return CGSize(width: 24, height: 24)
      case .large:
        return CGSize(width: 24, height: 24)
      case .medium:
        return CGSize(width: 20, height: 20)
      case .small:
        return CGSize(width: 16, height: 16)
      case .xSmall:
        return CGSize(width: 16, height: 16)
    }
  }
}
