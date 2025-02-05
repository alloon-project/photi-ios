//
//  FilledRoundButton.swift
//  DesignSystem
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

/// 내부가 색으로 채워진 Round Button입니다.
public final class FilledRoundButton: RoundButton {
  // MARK: - Properties
  /// Round Button의 type입니다.
  public let type: RoundButtonType
  
  /// Round Button의 mode입니다.
  public var mode: ButtonMode {
    didSet { setupUI(type: type, mode: mode) }
  }
  
  public var title: String {
    didSet { setText(title) }
  }
  
  public var icon: UIImage? {
    didSet {
      iconView.isHidden = icon == nil
      setIcon(icon)
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
  
  // MARK: - UI Components
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.alignment = .center
    stackView.distribution = .fill
    
    return stackView
  }()
  
  private let iconView = UIImageView()
  private let label = UILabel()
  
  // MARK: - Initalizers
  public init(
    type: RoundButtonType,
    size: ButtonSize,
    text: String,
    icon: UIImage?,
    mode: ButtonMode = .default
  ) {
    self.type = type
    self.mode = mode
    self.title = text
    self.icon = icon
    super.init(size: size)
    
    setupUI()
    setText(text)
    setIcon(icon)
  }
  
  public convenience init(
    type: RoundButtonType,
    size: ButtonSize,
    text: String,
    mode: ButtonMode = .default
  ) {
    self.init(type: type, size: size, text: text, icon: nil)
  }
  
  public convenience init(
    type: RoundButtonType,
    size: ButtonSize,
    mode: ButtonMode = .default
  ) {
    self.init(type: type, size: size, text: "", icon: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension FilledRoundButton {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    iconView.isHidden = icon == nil
    self.setupUI(type: type, mode: mode)
  }
  
  func setViewHierarchy() {
    addSubviews(stackView)
    stackView.addArrangedSubviews(iconView, label)
  }
  
  func setConstraints() {
    stackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    iconView.snp.makeConstraints {
      $0.width.height.equalTo(iconViewSize(for: size))
    }
  }
}

// MARK: - Public Methods
public extension FilledRoundButton {
  func setText(_ text: String) {
    label.attributedText = text.attributedString(
      font: font(for: size),
      color: .photiWhite
    )

    if type == .quaternary {
      quatenaryConvertTextColor(mode: mode)
    }
  }
  
  func setIcon(_ icon: UIImage?) {
    guard let icon else { return }
    let color: UIColor =  type == .quaternary ? .gray600 : .photiWhite
    
    iconView.image = icon.color(color)
  }
}

// MARK: - Private Methods
private extension FilledRoundButton {
  func setupUI(type: RoundButtonType, mode: ButtonMode) {
    self.backgroundColor = backGroundColor(type: self.type, mode: mode)
    
    if type == .quaternary {
      quatenaryConvertIconColor(mode: mode)
      quatenaryConvertTextColor(mode: mode)
    }
  }
  
  func iconViewSize(for size: ButtonSize) -> CGFloat {
    switch size {
      case .xLarge, .large, .medium:
        return 18
      case .small, .xSmall:
        return 16
    }
  }
  
  func quatenaryConvertIconColor(mode: ButtonMode) {
    guard let icon = iconView.image else { return }
    
    switch mode {
      case .default: iconView.image = icon.color(.gray600)
      case .disabled: iconView.image = icon.color(.gray800)
      case .pressed: iconView.image = icon.color(.gray500)
    }
  }
  
  func quatenaryConvertTextColor(mode: ButtonMode) {
    guard let text = label.attributedText else { return }
    
    switch mode {
      case .default: label.attributedText = text.setColor(.gray600)
      case .disabled: label.attributedText = text.setColor(.gray800)
      case .pressed: label.attributedText = text.setColor(.gray500)
    }
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
