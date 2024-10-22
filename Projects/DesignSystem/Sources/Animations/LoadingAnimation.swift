//
//  LoadingAnimation.swift
//  DesignSystem
//
//  Created by jung on 10/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Lottie
import SnapKit
import Core

public final class LoadingAnimation {
  private let animationView: LottieAnimationView
  
  // MARK: - Initializers
  public init(loopMode: LottieLoopMode = .loop) {
    self.animationView = .init(name: "loading_logo")
    animationView.loopMode = loopMode
  }
  
  public func start(at view: UIView? = UIWindow.key) {
    guard let view = view else { return }
    
    view.addSubview(animationView)
    animationView.frame.size = .init(width: 130, height: 130)
    animationView.center = view.center
    animationView.contentMode = .scaleAspectFit
    animationView.play()
  }
  
  public func stop() {
    animationView.stop()
    animationView.removeFromSuperview()
  }
}
