//
//  DashLineSegmentButton.swift
//  DesignSystem
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Core

final class DashLineSegmentButton: SegmentButton {
  override var textColor: UIColor {
    return isSelected ? .gray800 : .white
  }

  // MARK: - UI Components
  private let dashLine = CAShapeLayer()
  
  // MARK: - laytoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    configureDashLine()
  }
  
  // MARK: - Setup UI
  override func setupUI() {
    layer.cornerRadius = 12
    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    layer.addSublayer(dashLine)
    setupUI(for: isSelected)
  }
  
  override func setupUI(for isSelected: Bool) {
    super.setupUI(for: isSelected)
    let alphaComponent: CGFloat = isSelected ? 1.0 : 0.3
    
    backgroundColor = .white.withAlphaComponent(alphaComponent)
    dashLine.isHidden = !isSelected
    
  }
}

// MARK: - UI Methods
private extension DashLineSegmentButton {
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
}
