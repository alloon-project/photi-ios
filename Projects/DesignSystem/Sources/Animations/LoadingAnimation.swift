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
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .init(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4)
    
    return view
  }()
  
  // MARK: - Initializers
  public init(loopMode: LottieLoopMode = .loop) {
    self.animationView = .init(name: "loading_logo")
    animationView.loopMode = loopMode
  }
  
  public func start(at view: UIView? = UIWindow.key) {
    guard let view = view else { return }
    view.addSubview(dimmedView)
    view.addSubview(animationView)
    dimmedView.frame = view.bounds
    animationView.frame.size = .init(width: 130, height: 130)
    animationView.center = view.center
    animationView.contentMode = .scaleAspectFit
    animationView.play()
  }
  
  public func stop() {
    animationView.stop()
    dimmedView.removeFromSuperview()
    animationView.removeFromSuperview()
  }
}
