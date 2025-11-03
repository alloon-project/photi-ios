//
//  PhotiTextField.swift
//  DesignSystem
//
//  Created by jung on 5/6/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public class PhotiTextField: UITextField {
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: 327, height: 46)
  }
  
  public override var isSecureTextEntry: Bool {
    didSet {
      if isFirstResponder { becomeFirstResponder() }
    }
  }
  
  public override var placeholder: String? {
    didSet { self.setPlaceholder(placeholder) }
  }
  
  public override var text: String? {
    didSet { setText(text) }
  }
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    setupUI()
    self.autocapitalizationType = .none
    
    self.addTarget(
      self,
      action: #selector(textDidChange),
      for: .editingChanged
    )
  }
  
  public convenience init(text: String) {
    self.init()
    self.text = text
  }
  
  public convenience init(placeholder: String) {
    self.init()
    self.placeholder = placeholder
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UIResponder
  @discardableResult
  public override func becomeFirstResponder() -> Bool {
    let success = super.becomeFirstResponder()
    
    if isSecureTextEntry, let text = text {
      self.text?.removeAll()
      insertText(text)
    }
    
    return success
  }
}

// MARK: - UI Methods
private extension PhotiTextField {
  func setupUI() {
    layer.cornerRadius = 14
    layer.borderWidth = 1
    
    addLeftPadding()
  }
  
  func addLeftPadding() {
    let paddingView = UIView(
      frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height)
    )
    self.leftView = paddingView
    self.leftViewMode = ViewMode.always
  }
}

// MARK: - Internel Extensions
extension PhotiTextField {
  func setLineColor(_ color: UIColor) {
    self.layer.borderColor = color.cgColor
  }
  
  func setText(_ text: String?) {
    self.attributedText = (text ?? "").attributedString(
      font: .body2,
      color: .photiBlack
    )
  }
  
  func setPlaceholder(_ placeholder: String?) {
    attributedPlaceholder = (placeholder ?? "").attributedString(
      font: .body2,
      color: .gray400
    )
  }
  
  func removeDefaultTarget() {
    self.removeTarget(self, action: #selector(textDidChange), for: .editingChanged)
  }
}

// MARK: - Private Extensions
private extension PhotiTextField {
  @objc func textDidChange() {
    self.setText(text)
  }
}
