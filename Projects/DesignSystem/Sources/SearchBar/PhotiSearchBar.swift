//
//  PhotiSearchBar.swift
//  DesignSystem
//
//  Created by jung on 5/8/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

/// Photi의 searchBar입니다.
public final class PhotiSearchBar: UITextField {
  public override var intrinsicContentSize: CGSize {
    CGSize(width: 327, height: 44)
  }
  
  /// searchBar의 placeholder입니다.
  public override var placeholder: String? {
    didSet { setPlaceholder(placeholder) }
  }
  
  /// searchBar의 text입니다.
  public override var text: String? {
    didSet { setText(text) }
  }
   
  private var currentRightButtonImage = UIImage.searchGray400 {
    didSet {
      guard currentRightButtonImage != oldValue else { return }
      rightButton.setImage(currentRightButtonImage, for: .normal)
      rightButton.setImage(currentRightButtonImage, for: .highlighted)
    }
  }
  private let bookmarkImage = UIImage.searchGray400
  private let closeImage = UIImage.closeCircleGray400
  
  // MARK: - UI Components
  private let rightButton = UIButton()
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    setupUI()
    
    self.addTarget(
      self,
      action: #selector(textDidChange),
      for: .editingChanged
    )
    
    rightButton.addTarget(
      self,
      action: #selector(rightButtonDidTapped),
      for: .touchUpInside
    )
  }
  
  public convenience init(placeholder: String, text: String = "") {
    self.init()
    self.placeholder = placeholder
    self.text = text
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = intrinsicContentSize.height / 2
  }
}

// MARK: - UI Methods
private extension PhotiSearchBar {
  func setupUI() {
    backgroundColor = .gray0
    addLeftPadding()
    addRightButton()
  }
}

// MARK: - Private Methods
private extension PhotiSearchBar {
  func addLeftPadding() {
    let paddingView = UIView()
    let viewSize = CGSize(width: 16, height: 0)
    setLeftView(
      paddingView,
      size: viewSize,
      leftPdding: 0,
      rightPadding: 0
    )
  }

  func addRightButton() {
    let buttonSize = CGSize(width: 24, height: 24)
    rightButton.setImage(bookmarkImage, for: .normal)
    rightButton.setImage(bookmarkImage, for: .highlighted)
    
    setRightView(rightButton, size: buttonSize, leftPdding: 39, rightPadding: 16)
  }
  
  func setText(_ text: String?) {
    attributedText = (text ?? "").attributedString(
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
}

// MARK: - Actions
@objc private extension PhotiSearchBar {
  func textDidChange() {
    setText(text)
    
    if let text = text, !text.isEmpty {
      currentRightButtonImage = closeImage
      rightButton.isEnabled = true
    } else {
      currentRightButtonImage = bookmarkImage
      rightButton.isEnabled = false
    }
  }
  
  func rightButtonDidTapped() {
    text = ""
    sendActions(for: .editingChanged)
  }
}
