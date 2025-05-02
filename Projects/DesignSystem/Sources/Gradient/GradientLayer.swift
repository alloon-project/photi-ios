//
//  GradientLayer.swift
//  DesignSystem
//
//  Created by jung on 5/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit

public final class GradientLayer: CAGradientLayer {
  public enum GradientMode {
    /// 위에서 아래로 색이 진해집니다.
    case topToBottom
    /// 아래에서 위로 색이 진해집니다.
    case bottomToTop
  }
  
  public init(
    mode: GradientMode,
    minColor: UIColor,
    maxColor: UIColor
  ) {
    super.init()
    colors = [maxColor.cgColor, minColor.cgColor]
    
    if mode == .bottomToTop { colors?.reverse() }
    
    locations = [0, 1]
    startPoint = CGPoint(x: 0, y: 0)
    endPoint = CGPoint(x: 0, y: 1)
    compositingFilter = "multiplyBlendMode"
  }
  
  public convenience init(mode: GradientMode, maxColor: UIColor) {
    let minColor = maxColor.withAlphaComponent(0)
    self.init(mode: mode, minColor: minColor, maxColor: maxColor)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
