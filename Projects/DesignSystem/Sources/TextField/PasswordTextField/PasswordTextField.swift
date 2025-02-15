//
//  PasswordTextField.swift
//  DesignSystem
//
//  Created by jung on 5/8/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

/// content를 show 혹은 off 할 수 있는 TextField입니다.
public final class PasswordTextField: LineTextField {
  private let secureButton: IconButton = {
    let iconButton = IconButton(size: .medium)
    iconButton.selectedTintColor = .gray500
    iconButton.unSelectedTintColor = .gray500
    
    iconButton.unSelectedIcon = .eyeOffGray400
    iconButton.selectedIcon = .eyeOnGray700
    iconButton.invalidateIntrinsicContentSize()
    
    return iconButton
  }()
  
  public private(set) var isSecureTextEntry: Bool {
    get {
      return textField.isSecureTextEntry
    }
    set {
      textField.isSecureTextEntry = newValue
      secureButton.isSelected = !newValue
    }
  }
  
  // MARK: - Setup UI
  override func setupUI() {
    super.setupUI()
    
    isSecureTextEntry = true
    secureButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    
    textField.setRightView(
      secureButton,
      size: CGSize(width: 32, height: 32),
      leftPdding: 8,
      rightPadding: 9
    )
  }
}

// MARK: - private Extension
private extension PasswordTextField {
  @objc func didTapButton() {
    textField.isSecureTextEntry.toggle()
  }
}
