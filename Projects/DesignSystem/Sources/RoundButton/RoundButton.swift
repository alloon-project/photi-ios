//
//  RoundButton.swift
//  DesignSystem
//
//  Created by jung on 5/1/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

open class RoundButton: UIButton {
  /// Round Button의 size입니다.
  public let size: RoundButtonSize
  
  open override var intrinsicContentSize: CGSize {
    self.cgSize(for: size)
  }
  
  public init(size: RoundButtonSize) {
    self.size = size
    super.init(frame: .zero)
  }
  
  @available(*, unavailable)
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func setupUI() {
    layer.cornerRadius = cornerRadius(for: size)
    titleLabel?.font = font(for: size)
  }
}

// MARK: - Internal Methods
extension RoundButton {
  func cornerRadius(for size: RoundButtonSize) -> CGFloat {
    switch size {
      case .xLarge, .large:
        return 16
      case .medium:
        return 14
      case .small:
        return 12
      case .xSmall:
        return 10
    }
  }
  
  func font(for size: RoundButtonSize) -> UIFont {
    switch size {
      case .xLarge, .large, .medium:
        return .body1
      case .small, .xSmall:
        return .body2
    }
  }
  
  func cgSize(for size: RoundButtonSize) -> CGSize {
    switch size {
      case .xLarge:
        return CGSize(width: 327, height: 56)
      case .large:
        return CGSize(width: 279, height: 56)
      case .medium:
        return CGSize(width: 156, height: 52)
      case .small:
        return CGSize(width: 136, height: 46)
      case .xSmall:
        return CGSize(width: 70, height: 34)
    }
  }
  
  func setAttributedTitleColor(_ color: UIColor) {
    guard let currentAttributedTitle = self.attributedTitle(for: .normal) else {
      return
    }
    
    let attributedTitle = NSMutableAttributedString(attributedString: currentAttributedTitle)
    attributedTitle.addAttribute(
      .foregroundColor,
      value: color, range: NSRange(location: 0, length: currentAttributedTitle.length)
    )
    
    self.setAttributedTitle(attributedTitle, for: state)
  }
}
