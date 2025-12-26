//
//  UnlockButton.swift
//  HomeImpl
//
//  Created by jung on 1/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import CoreUI
import DesignSystem

final class UnlockButton: UIButton {
  enum Constants {
    static let imageSize = CGSize(width: 24, height: 24)
  }
  
  private let lockImage: UIImage = .lockClosedWhite.resize(Constants.imageSize)
  private let unLockImage: UIImage = .lockOpenWhite.resize(Constants.imageSize)
  
  var isLocked = true {
    didSet { configureUI(isLocked: isLocked, isEnabled: isEnabled) }
  }
  
  override var isEnabled: Bool {
    didSet { configureUI(isLocked: isLocked, isEnabled: isEnabled) }
  }
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
  }
}

// MARK: - UI Methods
private extension UnlockButton {
  func setupUI() {
    configureUI(isLocked: isLocked, isEnabled: isEnabled)
  }
}

// MARK: - Private Methods
private extension UnlockButton {
  func configureUI(isLocked: Bool, isEnabled: Bool) {
    self.backgroundColor = backgroundColor(isLocked: isLocked, isEnabled: isEnabled)
    let image: UIImage = isLocked ? lockImage : unLockImage
    setImage(image, for: .normal)
    setImage(image, for: .disabled)
  }
  
  func backgroundColor(isLocked: Bool, isEnabled: Bool) -> UIColor {
    guard isLocked else { return .green500 }
    
    return isEnabled ? .blue500 : .blue200
  }
}
