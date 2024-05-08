//
//  IconTextField.swift
//  DesignSystem
//
//  Created by jung on 5/8/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

/// 왼쪽에 icon이 있는 textField입니다.
public final class IconTextField: LineTextField {
  public var icon: UIImage {
    didSet {
      setIconView(icon)
    }
  }
  
  private let imageView = UIImageView()
  
  // MARK: - Initalizers
  public init(
    icon: UIImage,
    type: TextFieldType,
    mode: TextFieldMode = .default
  ) {
    self.icon = icon
    super.init(type: type, mode: mode)
  }
  
  public convenience init(
    icon: UIImage,
    placeholder: String,
    text: String = "",
    type: TextFieldType,
    mode: TextFieldMode = .default
  ) {
    self.init(icon: icon, type: type, mode: mode)
    self.placeholder = placeholder
    self.text = text
  }
  
  // MARK: - Setup UI
  override func setupUI() {
    super.setupUI()
    
    setIconView(icon)
    
    textField.setLeftView(
      imageView,
      size: CGSize(width: 24, height: 24),
      leftPdding: 12,
      rightPadding: 8
    )
  }
}

// MARK: - Private Extension
private extension IconTextField {
  func setIconView(_ icon: UIImage) {
    imageView.image = icon.resize(CGSize(width: 16, height: 16)).withTintColor(.gray600)
    imageView.contentMode = .center
    
  }
}
