//
//  UIBezierPath+Extension.swift
//  Core
//
//  Created by jung on 10/8/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public extension UIBezierPath {
  convenience init(
    for bounds: CGRect,
    leftTopSize: CGSize = .zero,
    rightTopSize: CGSize = .zero,
    leftBottomSize: CGSize = .zero,
    rightBottomSize: CGSize = .zero
  ) {
    self.init()
    
    let path = CGMutablePath()
    
    let leftTop: CGPoint = bounds.origin
    let rightTop: CGPoint = CGPoint(x: bounds.maxX, y: bounds.minY)
    let leftBottom: CGPoint = CGPoint(x: bounds.minX, y: bounds.maxY)
    let rightBottom: CGPoint = CGPoint(x: bounds.maxX, y: bounds.maxY)
    
    if leftTopSize != .zero {
      path.move(to: CGPoint(x: leftTop.x + leftTopSize.width, y: leftTop.y))
    } else {
      path.move(to: leftTop)
    }
    
    if rightTopSize != .zero {
      path.addLine(to: CGPoint(x: rightTop.x - rightTopSize.width, y: rightTop.y))

      let curvePoint = CGPoint(x: rightTop.x, y: rightTop.y + rightTopSize.height)
      let control1 = CGPoint(x: rightTop.x, y: rightTop.y)
      let control2 = CGPoint(x: rightTop.x, y: rightTop.y + rightTopSize.height)
      path.addCurve(to: curvePoint, control1: control1, control2: control2)
    } else {
      path.addLine(to: rightTop)
    }
    
    if rightBottomSize != .zero {
      path.addLine(to: CGPoint(x: rightBottom.x, y: rightBottom.y - rightBottomSize.height))
      
      let curvePoint = CGPoint(x: rightBottom.x - rightBottomSize.width, y: rightBottom.y)
      let control1 = CGPoint(x: rightBottom.x, y: rightBottom.y)
      let control2 = CGPoint(x: rightBottom.x - rightBottomSize.width, y: rightBottom.y)
      path.addCurve(to: curvePoint, control1: control1, control2: control2)
    } else {
      path.addLine(to: rightBottom)
    }
    
    if leftBottomSize != .zero {
      path.addLine(to: CGPoint(x: leftBottom.x + leftBottomSize.width, y: leftBottom.y))

      let curvePoint = CGPoint(x: leftBottom.x, y: leftBottom.y - leftBottomSize.height)
      let control1 = CGPoint(x: leftBottom.x, y: leftBottom.y)
      let control2 = CGPoint(x: leftBottom.x, y: leftBottom.y - leftBottomSize.height)
      path.addCurve(to: curvePoint, control1: control1, control2: control2)
    } else {
      path.addLine(to: leftBottom)
    }
    
    if leftTopSize != .zero {
      path.addLine(to: CGPoint(x: leftTop.x, y: leftTop.y + leftTopSize.height))

      let curvePoint = CGPoint(x: leftTop.x + leftTopSize.width, y: leftTop.y)
      let control1 = CGPoint(x: leftTop.x, y: leftTop.y)
      let control2 = CGPoint(x: leftTop.x + leftTopSize.width, y: leftTop.y)
      path.addCurve(to: curvePoint, control1: control1, control2: control2)
    } else {
      path.addLine(to: leftTop)
    }
    
    path.closeSubpath()
    cgPath = path
  }
}
