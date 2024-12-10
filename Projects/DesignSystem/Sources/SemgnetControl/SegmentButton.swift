//
//  SegmentButton.swift
//  DesignSystem
//
//  Created by jung on 12/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

final class SegmentButton: UIButton {
  override var isSelected: Bool {
    didSet { setupUI(for: isSelected) }
  }
  
  var title: String {
    didSet { setTitle(title) }
  }
  
  private var textColor: UIColor {
    return isSelected ? .gray800 : .white
  }

  // MARK: - UI Components
  private let dashLine = CAShapeLayer()

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
  
  // MARK: - laytoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    configureDashLine()
  }
}

// MARK: - UI Methods
private extension SegmentButton {
  func setupUI() {
    layer.cornerRadius = 12
    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    backgroundColor = .white
    
    layer.addSublayer(dashLine)
    setupUI(for: isSelected)
  }
  
  func configureDashLine() {
    dashLine.strokeColor = UIColor.gray300.cgColor
    dashLine.lineWidth = 1
    dashLine.fillColor = UIColor.clear.cgColor
    let path = CGMutablePath()
    
    let startPoint = CGPoint(x: 0, y: bounds.height - 1)
    let endPoint = CGPoint(x: bounds.width, y: bounds.height - 1)
    path.addLines(between: [startPoint, endPoint])

    dashLine.path = path
    dashLine.lineDashPattern = [5, 5]
  }
  
  func setupUI(for isSelected: Bool) {
    let alphaComponent: CGFloat = isSelected ? 1.0 : 0.3
    backgroundColor = .white.withAlphaComponent(alphaComponent)
    dashLine.isHidden = !isSelected
    setTitle(title)
  }
  
  func setTitle(_ title: String) {
    let attributeTitle: NSAttributedString = title.attributedString(
      font: .body2Bold,
      color: textColor
    )
    
    setAttributedTitle(attributeTitle, for: .normal)
  }
}
