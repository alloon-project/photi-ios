//
//  SegmentButton.swift
//  DesignSystem
//
//  Created by jung on 12/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

class SegmentButton: UIButton {
  override var isSelected: Bool {
    didSet { setupUI(for: isSelected) }
  }
  
  var title: String {
    didSet { setTitle(title) }
  }
  
  var textColor: UIColor {
    return .photiBlack
  }

  // MARK: - Initalizers
  init(title: String) {
    self.title = title
    super.init(frame: .zero)
    setupUI()
  }
  
  convenience init() {
    self.init(title: "")
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {
    setupUI(for: isSelected)
  }
  
  func setupUI(for isSelected: Bool) {
    setTitle(title)
  }
}

// MARK: - UI Methods
extension SegmentButton {
  func setTitle(_ title: String) {
    let attributeTitle: NSAttributedString = title.attributedString(
      font: .body2Bold,
      color: textColor
    )
    
    setAttributedTitle(attributeTitle, for: .normal)
  }
}
