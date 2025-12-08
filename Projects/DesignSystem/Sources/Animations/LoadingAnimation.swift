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
import CoreUI

public final class LoadingAnimation {
  public static let logo: LoadingAnimation = {
    let animation = LoadingAnimation(name: "loading_logo", bundle: .module)
    animation.animationSize = CGSize(width: 130, height: 130)
    
    return animation
  }()
  
  public var animationSize: CGSize = .zero
  public var dimmedBackgroundColor: UIColor? = .init(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4) {
    didSet {
      dimmedView.backgroundColor = dimmedBackgroundColor
    }
  }
  
  private let animationView: LottieAnimationView
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .init(red: 0.118, green: 0.136, blue: 0.149, alpha: 0.4)
    
    return view
  }()
  
  // MARK: - Initializers
  public init(name: String, bundle: Bundle, loopMode: LottieLoopMode = .loop) {
    self.animationView = .init(name: name, bundle: bundle)
    animationView.loopMode = loopMode
  }
  
  public func start(at view: UIView? = UIWindow.key) {
    guard let view = view else { return }
    view.addSubview(dimmedView)
    view.addSubview(animationView)
    dimmedView.frame = view.bounds
    animationView.frame.size = animationSize
    animationView.center = .init(
      x: view.frame.width / 2,
      y: view.frame.height / 2
    )
    animationView.contentMode = .scaleAspectFit
    animationView.play()
  }
  
  public func stop() {
    animationView.stop()
    dimmedView.removeFromSuperview()
    animationView.removeFromSuperview()
  }
}
