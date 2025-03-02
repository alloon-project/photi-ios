//
//  IconButtonType.swift
//  DesignSystem
//
//  Created by jung on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

/// Icon으로만 구성된 버튼입니다.
public final class IconButton: UIButton {
  /// Icon Button의 size입니다.
  private let size: ButtonSize
  
  public var selectedTintColor: UIColor = .photiWhite
  public var unSelectedTintColor: UIColor = .photiWhite
  
  /// 선택되었을 때의 이미지입니다.
  public var selectedIcon: UIImage {
    didSet {
      let imageSize = imageSize(for: size)
      resizeSelectedIcon = selectedIcon.resize(imageSize).withTintColor(selectedTintColor)
      setImage(for: isSelected)
    }
  }
  
  /// 선택되지 않았을 때의 이미지입니다.
  public var unSelectedIcon: UIImage {
    didSet {
      let imageSize = imageSize(for: size)
      resizeUnSelectedIcon = unSelectedIcon.resize(imageSize).withTintColor(unSelectedTintColor)
      setImage(for: isSelected)
    }
  }
  
  /// 내부적으로 사용되는 선택되었을 때의 이미지입니다.
  private lazy var resizeSelectedIcon: UIImage = selectedIcon
  
  /// 내부적으로 사용되는 선택되지 않았을 때의 이미지입니다.
  private lazy var resizeUnSelectedIcon: UIImage = unSelectedIcon
  
  public override var intrinsicContentSize: CGSize {
    cgSize(for: size)
  }
  
  public override var isSelected: Bool {
    didSet {
      setImage(for: isSelected)
    }
  }
  
  // MARK: - Initalizers
  public init(
    selectedIcon: UIImage,
    unSelectedIcon: UIImage,
    size: ButtonSize
  ) {
    self.selectedIcon = selectedIcon
    self.unSelectedIcon = unSelectedIcon
    self.size = size
    super.init(frame: .zero)
    setupUI()
    addTarget(self, action: #selector(didTap), for: .touchUpInside)
  }
  
  public convenience init(size: ButtonSize) {
    self.init(
      selectedIcon: .heartFilledWhite,
      unSelectedIcon: .heartWhite,
      size: size
    )
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
 
  // MARK: - layoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = bounds.size.width / 2
  }
  
  // MARK: - Point
  public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let circlePath = UIBezierPath(ovalIn: self.bounds)
    return circlePath.contains(point)
  }
  
  // MARK: - Setup UI
  func setupUI() {
    self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
    
    var config = UIButton.Configuration.plain()
    config.baseBackgroundColor = .clear
    self.configuration = config
    
    let imageSize = imageSize(for: size)
    self.selectedIcon = selectedIcon.resize(imageSize).withTintColor(selectedTintColor)
    self.unSelectedIcon = unSelectedIcon.resize(imageSize).withTintColor(unSelectedTintColor)
    
    setImage(for: isSelected)
  }
}

// MARK: - Private Methods
private extension IconButton {
  func setImage(for isSelected: Bool) {
    if isSelected {
      setImage(resizeSelectedIcon, for: .normal)
    } else {
      setImage(resizeUnSelectedIcon, for: .normal)
    }
  }
  
  func cgSize(for size: ButtonSize) -> CGSize {
    switch size {
      case .xLarge:
        return CGSize(width: 56, height: 56)
      case .large:
        return CGSize(width: 48, height: 48)
      case .medium:
        return CGSize(width: 42, height: 42)
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
        return CGSize(width: 22, height: 22)
      case .medium:
        return CGSize(width: 18, height: 18)
      case .small:
        return CGSize(width: 14, height: 14)
      case .xSmall:
        return CGSize(width: 12, height: 12)
    }
  }
  
  @objc func didTap() {
    isSelected.toggle()
  }
}
