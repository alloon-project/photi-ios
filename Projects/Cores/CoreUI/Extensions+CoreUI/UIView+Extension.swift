//
//  UIView+Extension.swift
//  Core
//
//  Created by jung on 4/30/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

public extension UIView {
  /// view의 identifier  (ex: `MyView.identifier`)
  static var identifier: String {
    String(describing: self)
  }
  
  /// view의 SafeArea를 리턴합니다.
  static var safeAreaInset: UIEdgeInsets {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    
    return keyWindow?.safeAreaInsets ?? .zero
  }
  
  /// 여러개의 subview들을 view에 추가합니다.
  /// - Parameter views: 추가할 subViews (ex: `view.addSubviews(view1, view2, view3)`)
  func addSubviews(_ views: UIView...) {
    views.forEach { addSubview($0) }
  }
  
  func drawShadow(
    color: UIColor,
    opacity: Float,
    radius: CGFloat,
    offset: CGSize = .zero
  ) {
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowRadius = radius
    layer.shadowOffset = offset
  }
  
  func roundCorners(
    leftTop: CGFloat = 0,
    rightTop: CGFloat = 0,
    leftBottom: CGFloat = 0,
    rightBottom: CGFloat = 0
  ) {
    let leftTopSize = CGSize(width: leftTop, height: leftTop)
    let rightTopSize = CGSize(width: rightTop, height: rightTop)
    let leftBottomSize = CGSize(width: leftBottom, height: leftBottom)
    let rightBottomSize = CGSize(width: rightBottom, height: rightBottom)
    let maskedPath = UIBezierPath(
      for: self.bounds,
      leftTopSize: leftTopSize,
      rightTopSize: rightTopSize,
      leftBottomSize: leftBottomSize,
      rightBottomSize: rightBottomSize
    )
    
    let shape = CAShapeLayer()
    shape.path = maskedPath.cgPath

    self.layer.mask = shape
  }
    
  func configureShapeBorder(width: CGFloat, strockColor: UIColor, backGroundColor: UIColor) {
    let borderLayer = CAShapeLayer()
    borderLayer.path = (layer.mask as? CAShapeLayer)?.path
    borderLayer.strokeColor = strockColor.cgColor
    borderLayer.fillColor = backGroundColor.cgColor
    borderLayer.lineWidth = width
    borderLayer.frame = bounds
    layer.addSublayer(borderLayer)
  }
}
