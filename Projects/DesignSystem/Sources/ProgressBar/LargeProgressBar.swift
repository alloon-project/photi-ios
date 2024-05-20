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
public final class LargeProgressBar: UIView {
  /// 현재 ProgressBar의 step 값입니다. 변경시 UI도 변경적용됩니다.
  public var step: AlloonProgressStep = .one {
    didSet {
      switch step {
      case .one:
        progressView.setProgress(0.2, animated: false)
      case .two:
        progressView.setProgress(0.4, animated: false)
      case .three:
        progressView.setProgress(0.6, animated: false)
      case .four:
        progressView.setProgress(0.8, animated: false)
      case .five:
        progressView.setProgress(1.0, animated: false)
      }
    }
  }
  
  private let progressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.trackTintColor = .gray200
    progressView.progressTintColor = .green400
    return progressView
  }()
  
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
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.addSubview(progressView)
  }
  
  func setConstraints() {
    progressView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
