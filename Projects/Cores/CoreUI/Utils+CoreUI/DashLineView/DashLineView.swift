//
//  DashLineView.swift
//  Core
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit

public final class DashLineView: UIView {
  private let shapeLayer = CAShapeLayer()
  private let lineDashPattern: [NSNumber]
  private let lineColor: UIColor
  
  public init(lineDashPattern: [NSNumber], lineColor: UIColor) {
    self.lineDashPattern = lineDashPattern
    self.lineColor = lineColor
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  private func setup() {
    shapeLayer.strokeColor = lineColor.cgColor
    shapeLayer.lineWidth = 1

    shapeLayer.lineDashPattern = lineDashPattern
    layer.addSublayer(shapeLayer)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: bounds.height / 2))
    path.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2))
    shapeLayer.path = path.cgPath
    shapeLayer.frame = bounds
  }
}
