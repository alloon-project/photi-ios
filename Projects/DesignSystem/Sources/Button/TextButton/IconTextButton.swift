//
//  IconTextButton.swift
//  DesignSystem
//
//  Created by jung on 5/3/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

/// Icon과 Text가 같이 있는 버튼입니다.
public final class IconTextButton: UIButton {
  /// Icon Text Button의 size입니다.
  public let size: ButtonSize
 
  /// Icon Text Button의 text입니다.
  public var text: String {
    didSet {
      setLabel(text)
    }
  }
  
  /// Icon Text Button의 image입니다.
  public var icon: UIImage {
    didSet {
      setIconView(icon)
    }
  }
  
  // MARK: - UI Components
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 6
    stackView.alignment = .center
    stackView.distribution = .fillProportionally
    
    return stackView
  }()
  
  private let label = UILabel()
  private let iconView = UIImageView()
  
  // MARK: - Initializers
  public init(
    text: String,
    icon: UIImage,
    size: ButtonSize
  ) {
    self.text = text
    self.icon = icon
    self.size = size
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup UI
  func setupUI() {
    stackView.addArrangedSubviews(label, iconView)
    addSubview(stackView)
    stackView.snp.makeConstraints { $0.center.equalToSuperview() }
    
    setLabel(text)
    setIconView(icon)
  }
}

// MARK: - Private Extension
private extension IconTextButton {
  func setLabel(_ text: String) {
    label.attributedText = text.attributedString(
      font: font(for: size),
      color: .gray600
    )
  }
  
  func setIconView(_ icon: UIImage) {
    let resizeIcon = icon.resize(iconSize(for: size)).withTintColor(.gray600)
    iconView.image = resizeIcon
  }
  
  func cgSize(for size: ButtonSize) -> CGSize {
    switch size {
      case .xLarge:
        return CGSize(width: 79, height: 38)
      case .large:
        return CGSize(width: 75, height: 37)
      case .medium:
        return CGSize(width: 66, height: 32)
      case .small:
        return CGSize(width: 63, height: 30)
      case .xSmall:
        return CGSize(width: 54, height: 22)
    }
  }
  
  func iconSize(for size: ButtonSize) -> CGSize {
    switch size {
      case .xLarge, .large:
        return CGSize(width: 14, height: 14)
      case .medium:
        return CGSize(width: 12, height: 12)
      case .small:
        return CGSize(width: 10, height: 10)
      case .xSmall:
        return CGSize(width: 9, height: 9)
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
