//
//  FeedCameraGradientView.swift
//  ChallengeImpl
//
//  Created by jung on 5/3/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import DesignSystem

final class FeedCameraGradientView: UIView {
  private let cameraGraidentLayer: GradientLayer = {
    let color = UIColor(red: 0.09, green: 0.09, blue: 0.098, alpha: 1)
    return .init(mode: .bottomToTop, maxColor: color)
  }()

  init() {
    super.init(frame: .zero)
    self.layer.addSublayer(cameraGraidentLayer)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    cameraGraidentLayer.frame = bounds
  }
}
