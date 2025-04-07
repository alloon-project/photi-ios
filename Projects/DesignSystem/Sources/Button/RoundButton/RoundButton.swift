//
//  RoundButton.swift
//  DesignSystem
//
//  Created by jung on 5/1/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Lottie

open class RoundButton: UIButton {
  /// Round Button의 size입니다.
  public let size: ButtonSize
  let loadingAnmationView: LoadingAnimation

  open override var intrinsicContentSize: CGSize {
    self.cgSize(for: size)
  }
  
  public init(size: ButtonSize) {
    self.size = size
    self.loadingAnmationView = .init(name: "loading_btn", bundle: .module)
    loadingAnmationView.animationSize = .init(width: 32, height: 32)
    super.init(frame: .zero)
    self.clipsToBounds = true
    setupUI()
  }
  
  @available(*, unavailable)
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Public Methods
public extension RoundButton {
  func startLoadingAnimation() {
    loadingAnmationView.start(at: self)
  }
  
  func stopLoadingAnimation() {
    loadingAnmationView.stop()
  }
}

// MARK: - UI Methods
private extension RoundButton {
  func setupUI() {
    layer.cornerRadius = cornerRadius(for: size)
    titleLabel?.font = font(for: size)
  }
}

// MARK: - Internal Methods
extension RoundButton {
  func cornerRadius(for size: ButtonSize) -> CGFloat {
    switch size {
      case .xLarge, .large:
        return 16
      case .medium:
        return 14
      case .small:
        return 12
      case .xSmall:
        return 10
    }
  }
  
  func font(for size: ButtonSize) -> UIFont {
    switch size {
      case .xLarge, .large, .medium:
        return .body1Bold
      case .small, .xSmall:
        return .body2Bold
    }
  }
  
  func cgSize(for size: ButtonSize) -> CGSize {
    switch size {
      case .xLarge:
        return CGSize(width: 327, height: 56)
      case .large:
        return CGSize(width: 279, height: 56)
      case .medium:
        return CGSize(width: 156, height: 52)
      case .small:
        return CGSize(width: 136, height: 46)
      case .xSmall:
        return CGSize(width: 70, height: 34)
    }
  }
}
