//
//  IconChip.swift
//  DesignSystem
//
//  Created by jung on 5/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import SnapKit
import Core

/// Text와 Icon이 있으며, 마찬가지로 Text 사이즈에 따라 유동적으로 길이가 변하는 View입니다.
public final class IconChip: UIView {
  /// Icon Chip의 size입니다.
  public let size: ChipSize
  
  /// Icon Chip의 type입니다.
  public let type: IconChipType
  
  /// Icon Chip의 text입니다.
  public var text: String {
    didSet {
      setLabel(text)
    }
  }
  
  /// Icon Chip의 Image입니다.
  public var icon: UIImage? {
    didSet {
      guard let icon else { return }
      setIconView(icon)
    }
  }
  
  // MARK: - UI Components
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 2
    stackView.alignment = .center
    stackView.distribution = .fillProportionally
    
    return stackView
  }()
  
  private let label = UILabel()
  fileprivate let iconView = UIImageView()
  
  // MARK: - Initializers
  public init(
    text: String,
    icon: UIImage?,
    type: IconChipType,
    size: ChipSize
  ) {
    self.text = text
    self.icon = icon
    self.type = type
    self.size = size
    super.init(frame: .zero)
    setupUI()
  }
  
  public convenience init(
    icon: UIImage,
    type: IconChipType,
    size: ChipSize
  ) {
    self.init(text: "", icon: icon, type: type, size: size)
  }
  
  public convenience init(type: IconChipType, size: ChipSize) {
    self.init(text: "", icon: nil, type: type, size: size)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.frame.height / 2
  }
}

// MARK: UI Methods
private extension IconChip {
  func setupUI() {
    self.backgroundColor = backgroundColor(for: type)
    
    setViewHierarchy()
    setConstraints(for: size)
    setBorderLine(for: type)
    setLabel(text)
    
    if let icon = icon { setIconView(icon) }
  }
  
  func setViewHierarchy() {
    addSubview(stackView)
    stackView.addArrangedSubviews(label, iconView)
  }
  
  func setConstraints(for size: ChipSize) {
    label.setContentHuggingPriority(.init(999), for: .horizontal)
    iconView.snp.makeConstraints { $0.size.equalTo(iconViewSize(for: self.size)) }
    
    switch size {
      case .large:
        stackView.spacing = 4
        stackView.snp.makeConstraints {
          $0.top.bottom.equalToSuperview().inset(8)
          $0.leading.equalToSuperview().offset(12)
          $0.trailing.equalToSuperview().offset(-10)
        }
      default:
        stackView.snp.makeConstraints {
          $0.top.bottom.equalToSuperview().inset(6)
          $0.leading.equalToSuperview().offset(8)
          $0.trailing.equalToSuperview().offset(-6)
        }
    }
  }
  
  func setBorderLine(for type: IconChipType) {
    switch type {
      case .line:
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray300.cgColor
      default: break
    }
  }
  
  func setLabel(_ text: String) {
    label.attributedText = text.attributedString(
      font: font(for: size),
      color: textColor(for: type)
    )
  }
  
  func setIconView(_ icon: UIImage) {
    let resizeIcon = icon
      .resize(iconSize(for: size))
      .color(iconColor(for: type))
    
    iconView.image = resizeIcon
    iconView.contentMode = .center
  }
}

// MARK: - Private Methods
private extension IconChip {
  func backgroundColor(for type: IconChipType) -> UIColor {
    switch type {
      case .line:
        return .photiWhite
      case .gray:
        return .gray0
      case .darkGray:
        return .gray200
      case .blue:
        return .blue100
      case .green:
        return .green0
    }
  }
  
  func textColor(for type: IconChipType) -> UIColor {
    switch type {
      case .line:
        return .gray800
      case .gray, .darkGray:
        return .gray600
      case .blue:
        return .blue500
      case .green:
        return .green600
    }
  }
  
  func iconColor(for type: IconChipType) -> UIColor {
    switch type {
      case .line:
        return .gray600
      case .gray:
        return .gray400
      case .darkGray:
        return .gray500
      case .blue:
        return .blue400
      case .green:
        return .green500
    }
  }
  
  func font(for size: ChipSize) -> UIFont {
    switch size {
      case .large:
        return .body2
      case .medium:
        return .caption1
      case .small:
        return .caption2
    }
  }
  
  func iconViewSize(for size: ChipSize) -> CGSize {
    switch size {
      case .large:
        return CGSize(width: 16, height: 16)
      case .medium:
        return CGSize(width: 14, height: 14)
      case .small:
        return CGSize(width: 12, height: 12)
    }
  }
  
  // TODO: - DS Image 적용 후 삭제 예정
  func iconSize(for size: ChipSize) -> CGSize {
    switch size {
      case .large:
        return CGSize(width: 8.5, height: 8.5)
      case .medium:
        return CGSize(width: 7.44, height: 7.44)
      case .small:
        return CGSize(width: 6.38, height: 6.38)
    }
  }
}

// MARK: - Reative Extension
public extension Reactive where Base: IconChip {
  var didTapIcon: ControlEvent<Void> {
    let base = base.iconView.rx.tapGesture().when(.recognized).map { _ in }
    return ControlEvent(events: base)
  }
}
