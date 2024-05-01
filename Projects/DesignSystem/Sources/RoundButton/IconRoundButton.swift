//
//  IconRoundButton.swift
//  DesignSystem
//
//  Created by jung on 5/1/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

public final class IconRoundButton: RoundButton {
  /// Round Button의 type입니다.
  public let type: RoundButtonType
  
  // MARK: - UI Components
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.alignment = .center
    stackView.distribution = .fillProportionally
    
    return stackView
  }()
  
  // MARK: - Initiazliers
  public init(
    text: String,
    icon: UIImage,
    type: RoundButtonType,
    size: RoundButtonSize
  ) {
    self.type = type
    super.init(size: size)
    setupUI()
    setStackViewSubviews(text, icon)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup UI
  public override func setupUI() {
    super.setupUI()
    self.backgroundColor = backGroundColor(for: type)
    
    self.addSubview(stackView)
    stackView.snp.makeConstraints { $0.center.equalToSuperview() }
  }
}

// MARK: - Private Methods
private extension IconRoundButton {
  func setStackViewSubviews(_ text: String, _ icon: UIImage) {
    let height = innerViewHeight(for: size)
    var textColor: UIColor = .alloonWhite
    
    if case .quaternary = type {
      textColor = .gray600
    }
    
    // UI Components
    let resizeIcon = icon.resize(CGSize(width: height, height: height)).withTintColor(textColor)
    let imageView = UIImageView(image: resizeIcon)
    let label = UILabel()
    
    label.attributedText = text.attributedString(
      font: font(for: size),
      color: textColor
    )
    
    self.stackView.addArrangedSubviews(imageView, label)
  }
  
  func innerViewHeight(for size: RoundButtonSize) -> CGFloat {
    switch size {
      case .xLarge:
        return 24
      case .large:
        return 22
      case .medium:
        return 20
      case .small, .xSmall:
        return 16
    }
  }
  
  func backGroundColor(for type: RoundButtonType) -> UIColor {
    switch type {
      case .primary:
        return .green400
      case .secondary:
        return .pink400
      case .tertiary:
        return .blue400
      case .quaternary:
        return .gray100
    }
  }
}
