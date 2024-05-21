//
//  LargeProgressBar.swift
//  DesignSystem
//
//  Created by wooseob on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit

/// Large Size에 해당하는 Progress Bar입니다.
///
/// ![LargeProgressBar](LargeProgressBar)
public final class LargeProgressBar: UIProgressView {
  /// 현재 ProgressBar의 step 값입니다. 변경시 UI도 변경적용됩니다.
  public var step: AlloonProgressStep = .one {
    didSet {
      switch step {
      case .one:
        self.setProgress(0.2, animated: true)
      case .two:
        self.setProgress(0.4, animated: true)
      case .three:
        self.setProgress(0.6, animated: true)
      case .four:
        self.setProgress(0.8, animated: true)
      case .five:
        self.setProgress(1.0, animated: true)
      }
    }
  }
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private Methods
private extension LargeProgressBar {
  func setupUI() {
    self.trackTintColor = .gray200
    self.progressTintColor = .green400
  }
}
