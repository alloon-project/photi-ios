//
//  AlloonTextView.swift
//  DesignSystem
//
//  Created by jung on 5/9/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

public final class AlloonTextView: UITextView {
  /// 현재 TextView의 TextType을 나타냅니다.
  public enum TextType {
    case text
    case placeholder
  }
  
  /// TextView의 type입니다.
  var type: TextType = .placeholder {
    didSet {
      setText(for: type)
    }
  }
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: 327, height: 109)
  }
  
  public override var text: String! {
    didSet {
      setNormalText(text)
      type = .text
    }
  }
  
  public var placeholder: String? {
    didSet {
      self.setPlaceholder(placeholder)
      if text.isEmpty {
        setText(for: .placeholder)
      }
    }
  }
  
  public var attributedPlaceholder: NSAttributedString?
  public var attributedNormalText: NSAttributedString?
  
  public var isEditing: Bool {
    self.isFirstResponder
  }
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero, textContainer: nil)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private Extensions
private extension AlloonTextView {
  func setupUI() {
    layer.cornerRadius = 14
    layer.borderWidth = 1
    
    textContainerInset = .init(top: 18, left: 16, bottom: 18, right: 16)
    setText(for: .placeholder)
  }
}

// MARK: Internal Methods
extension AlloonTextView {
  func setLineColor(_ color: UIColor) {
    self.layer.borderColor = color.cgColor
  }
}

// MARK: - Private Extension
private extension AlloonTextView {
  func setText(for type: TextType) {
    switch type {
      case .text:
        self.attributedText = attributedNormalText
      case .placeholder:
        self.attributedText = attributedPlaceholder
    }
  }
  
  func setNormalText(_ text: String?) {
    self.attributedNormalText = (text ?? "").attributedString(
      font: .body2,
      color: .alloonBlack
    )
  }
  
  func setPlaceholder(_ placeholder: String?) {
    self.attributedPlaceholder = (placeholder ?? "").attributedString(
      font: .body2,
      color: .gray400
    )
  }
}
