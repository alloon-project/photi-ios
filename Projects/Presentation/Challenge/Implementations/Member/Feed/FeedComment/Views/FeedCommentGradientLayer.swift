//
//  FeedGradientLayer.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import DesignSystem

final class FeedCommentGradientLayer: CAGradientLayer {
  enum GradientMode {
    case topToBottom
    case bottomToTop
  }
  
  init(mode: GradientMode, maxAlpha: CGFloat) {
    super.init()
    colors = [
      UIColor(red: 0.118, green: 0.136, blue: 0.149, alpha: maxAlpha).cgColor,
      UIColor(red: 0.118, green: 0.137, blue: 0.149, alpha: 0).cgColor
    ]
    
    if mode == .bottomToTop { colors?.reverse() }
    
    locations = [0, 1]
    startPoint = CGPoint(x: 0, y: 0)
    endPoint = CGPoint(x: 0, y: 1)
    compositingFilter = "multiplyBlendMode"
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
