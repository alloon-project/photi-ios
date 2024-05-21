//
//  AlloonTextField.swift
//  DesignSystem
//
//  Created by jung on 5/6/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public class AlloonTextField: UITextField {
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: 327, height: 46)
  }
  
  public override var placeholder: String? {
    didSet {
      self.setPlaceholder(placeholder)
    }
  }
  
  public override var text: String? {
    didSet {
      setText(text)
    }
  }
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    setupUI()
    
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
}

// MARK: - UI Methods
private extension AlloonTextField {
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
extension AlloonTextField {
  func setRightView(
    _ rightView: UIView,
    size: CGSize,
    leftPdding: CGFloat,
    rightPadding: CGFloat,
    viewMode: UITextField.ViewMode = .always
  ) {
    let totalViewSize = CGSize(
      width: size.width + leftPdding + rightPadding,
      height: size.height
    )
    let rightViewOrigin = CGPoint(x: leftPdding, y: 0)
    
    let totalView = UIView(frame: .init(origin: .zero, size: totalViewSize))
    totalView.addSubview(rightView)
    rightView.frame = .init(origin: rightViewOrigin, size: size)
    
    self.rightView = totalView
    rightViewMode = viewMode
  }
  
  func setLeftView(
    _ leftView: UIView,
    size: CGSize,
    leftPdding: CGFloat,
    rightPadding: CGFloat,
    viewMode: UITextField.ViewMode = .always
  ) {
    let totalViewSize = CGSize(
      width: size.width + leftPdding + rightPadding,
      height: size.height
    )
    let leftViewOrigin = CGPoint(x: leftPdding, y: 0)
    
    let totalView = UIView(frame: .init(origin: .zero, size: totalViewSize))
    totalView.addSubview(leftView)
    leftView.frame = .init(origin: leftViewOrigin, size: size)
    
    self.leftView = totalView
    leftViewMode = viewMode
  }
  
  func setLineColor(_ color: UIColor) {
    self.layer.borderColor = color.cgColor
  }
  
  func setText(_ text: String?) {
    self.attributedText = (text ?? "").attributedString(
      font: .body2,
      color: .alloonBlack
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
private extension AlloonTextField {
  @objc func textDidChange() {
    self.setText(text)
  }
}
