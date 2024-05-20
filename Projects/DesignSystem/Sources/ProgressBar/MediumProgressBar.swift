//
//  MediumProgressBar.swift
//  DesignSystem
//
//  Created by wooseob on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit

/// Medium Size에 해당하는 Progress Bar입니다. 
///
/// ![MediumProgressBar](MediumProgressBar)
public final class MediumProgressBar: UIView {
  /// 현재 ProgressBar의 Percent값입니다. 변경시 UI도 변경적용됩니다.
  public var percent: AlloonProgressPercent = .percent0 {
    didSet {
      switch percent {
      case .percent20:
        self.progressView.setProgress(0.2, animated: false)
      case .percent40:
        self.progressView.setProgress(0.4, animated: false)
      case .percent60:
        self.progressView.setProgress(0.6, animated: false)
      case .percent80:
        self.progressView.setProgress(0.8, animated: false)
      case .percent100:
        self.progressView.setProgress(1.0, animated: false)
      case .percent0:
        self.progressView.setProgress(0.0, animated: false)
      }
    }
  }

  private let progressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.trackTintColor = .gray200
    progressView.progressTintColor = .blue300
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
private extension MediumProgressBar {
  func setupUI() {
    self.clipsToBounds = true // 좌측 round처리 안되도록
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.addSubview(progressView)
  }
  
  func setConstraints() {
    progressView.snp.makeConstraints {
      $0.top.trailing.bottom.equalToSuperview()
      $0.leading.equalToSuperview().offset(-5)
    }
  }
}
