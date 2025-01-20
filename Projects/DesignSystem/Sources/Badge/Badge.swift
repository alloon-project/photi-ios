//
//  Badge.swift
//  DesignSystem
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Core

public final class Badge: UILabel {
  // MARK: - Properties
  public let size: BadgeSize
  public let mode: BadgeMode
  
  public override var intrinsicContentSize: CGSize {
    let contentSize = super.intrinsicContentSize
    let inset = badgeInset(for: size)
    return CGSize(
      width: contentSize.width + inset * 2,
      height: contentSize.height + inset * 2
    )
  }
  
  public override var text: String? {
    didSet {
      configureText(text ?? "")
    }
  }
  
  // MARK: - Initializers
  public init(mode: BadgeMode, size: BadgeSize, text: String) {
    self.mode = mode
    self.size = size
    super.init(frame: .zero)
    self.text = text
    
    setupUI()
  }
  
  public convenience init(mode: BadgeMode, size: BadgeSize) {
    self.init(mode: mode, size: size, text: "")
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - drawText
  public override func drawText(in rect: CGRect) {
    let inset = badgeInset(for: size)
    let edgeInset = UIEdgeInsets(
      top: inset,
      left: inset,
      bottom: inset,
      right: inset
    )
    super.drawText(in: rect.inset(by: edgeInset))
  }
}

// MARK: - UI Methods
private extension Badge {
  func setupUI() {
    self.layer.cornerRadius = 4
    
    switch mode {
      case .line: setupLineBadgeUI()
      case .gray: setupGrayBadgeUI()
    }
  }
  
  func setupLineBadgeUI() {
    layer.borderWidth = 1
    layer.borderColor = UIColor.gray300.cgColor
  }
  
  func setupGrayBadgeUI() {
    backgroundColor = .gray100
  }
}

// MARK: - Private Methods
private extension Badge {
  func badgeInset(for size: BadgeSize) -> CGFloat {
    switch size {
      case .large: return 8
      case .medium, .small: return 6
    }
  }
  
  func font(for size: BadgeSize) -> UIFont {
    switch size {
      case .large: return .body2Bold
      case .medium: return .caption1Bold
      case .small: return .caption2Bold
    }
  }
  
  func textColor(for mode: BadgeMode) -> UIColor {
    switch mode {
      case .line: return .gray500
      case .gray: return .gray600
    }
  }
  
  func configureText(_ text: String) {
    self.attributedText = text.attributedString(
      font: font(for: size),
      color: textColor(for: mode)
    )
  }
}
