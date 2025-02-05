//
//  InvitationCodeTextField.swift
//  HomeImpl
//
//  Created by jung on 1/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Core
import DesignSystem

final class InvitationCodeTextField: UITextField {
  let maximumCodeLength: Int
  
  override var placeholder: String? {
    didSet {
      guard let placeholder else { return }
      configurePlaceHolder(placeholder)
    }
  }
  
  override var text: String? {
    didSet {
      guard let text else { return }
      configureText(text)
    }
  }
  
  // MARK: - Initializers
  init(maximumCodeLength: Int) {
    self.maximumCodeLength = maximumCodeLength
    
    super.init(frame: .zero)
    setupUI()
    
    let placeholderText = "\(maximumCodeLength)글자"
    self.placeholder = placeholderText
    configurePlaceHolder(placeholderText)
    addTarget(self, action: #selector(textDidChange), for: .editingChanged)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension InvitationCodeTextField {
  func setupUI() {
    self.layer.cornerRadius = 14
    self.textAlignment = .center
    self.backgroundColor = .gray0
  }
}

// MARK: - Private Methods
private extension InvitationCodeTextField {
  @objc func textDidChange() {
    guard var text else { return }
    
    if text.count > maximumCodeLength {
      text = text.trimmingPrefix(count: maximumCodeLength)
    }
    configureText(text)
  }
  
  func configurePlaceHolder(_ placeholder: String) {
    attributedPlaceholder = placeholder.attributedString(
      font: .body2,
      color: .gray500,
      alignment: .center
    )
  }
  
  func configureText(_ text: String) {
    attributedText = text.attributedString(
      font: .body2,
      color: .gray900,
      alignment: .center
    )
  }
}
