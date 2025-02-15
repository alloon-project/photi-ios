//
//  LeftViewTextField.swift
//  Presentation
//
//  Created by jung on 12/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import DesignSystem

final class LeftImageTextField: UITextField {
  override var text: String? {
    didSet {
      setText(text)
    }
  }
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension LeftImageTextField {
  func setupUI() {
    setLeftImageView()
    backgroundColor = .white.withAlphaComponent(0.3)
    layer.cornerRadius = 10
    attributedPlaceholder = "한 줄 댓글을 남겨보세요".attributedString(
      font: .body2Bold,
      color: .gray300
    )
  }
  
  func setLeftImageView() {
    let leftImage = UIImage.writeGray400.withAlignmentRectInsets(
      .init(
        top: -2,
        left: -4,
        bottom: -3,
        right: -1
      )
    )
    let leftImageSize = CGSize(width: 19, height: 19)
    setleftImage(
      leftImage,
      size: leftImageSize,
      leftPadding: 10,
      rightPadding: 10
    )
  }
}

// MARK: - Private Methods
private extension LeftImageTextField {
  func setText(_ text: String?) {
    attributedText = text?.attributedString(
      font: .body2Bold,
      color: .white
    )
  }
}
