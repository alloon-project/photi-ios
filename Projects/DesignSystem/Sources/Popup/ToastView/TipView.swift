//
//  TipView.swift
//  DesignSystem
//
//  Created by jung on 5/10/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

final class TipView: UIView {
  enum TipDirection {
    case top, bottom
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 14, height: 14)
  }
  
  private let fillColor: UIColor
  private let tipDirection: TipDirection
  
  init(tipDirection: TipDirection, color: UIColor = .gray900) {
    self.fillColor = color
    self.tipDirection = tipDirection
    super.init(frame: .zero)
    self.layer.cornerRadius = 2
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    backgroundColor = .clear
    
    let triangle = CAShapeLayer()
    triangle.fillColor = fillColor.cgColor
    switch tipDirection {
      case .top:
        triangle.path = drawTopTip(rect)
      case .bottom:
        triangle.path = drawBottomTip(rect)
    }
    
    triangle.position = CGPoint(x: 0, y: 0)
    self.layer.addSublayer(triangle)
  }
}

// MARK: - Private Method
private extension TipView {
  func drawTopTip(_ rect: CGRect) -> CGPath {
    let path = CGMutablePath()
    
    let point1 = CGPoint(x: rect.midX, y: 0)
    let point2 = CGPoint(x: 0, y: rect.maxY)
    let point3 = CGPoint(x: rect.maxX, y: rect.maxY)
    
    path.move(to: point3)
    path.addArc(tangent1End: point1, tangent2End: point2, radius: 2)
    path.addArc(tangent1End: point2, tangent2End: point3, radius: 2)
    path.addArc(tangent1End: point3, tangent2End: point1, radius: 2)
    path.closeSubpath()
    
    return path
  }
  
  func drawBottomTip(_ rect: CGRect) -> CGPath {
    let path = CGMutablePath()
    
    let point1 = CGPoint(x: 0, y: 0)
    let point2 = CGPoint(x: rect.maxX, y: 0)
    let point3 = CGPoint(x: rect.midX, y: rect.maxY)
   
    path.move(to: point3)
    path.addArc(tangent1End: point1, tangent2End: point2, radius: 2)
    path.addArc(tangent1End: point2, tangent2End: point3, radius: 2)
    path.addArc(tangent1End: point3, tangent2End: point1, radius: 2)
    path.closeSubpath()
    
    return path
  }
}
