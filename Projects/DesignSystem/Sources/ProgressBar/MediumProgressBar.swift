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
public final class MediumProgressBar: UIProgressView {
  /// 현재 ProgressBar의 Percent값입니다. 변경시 UI도 변경적용됩니다.
  public var percent: PhotiProgressPercent {
    didSet { setPercentage(percent) }
  }
  
  // MARK: - Initializers
  public init(percent: PhotiProgressPercent) {
    self.percent = percent
    super.init(frame: .zero)
    setupUI()
  }
  
  public convenience init() {
    self.init(percent: .percent0)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Override Methods
  public override func layoutSubviews() {
    super.layoutSubviews()
    subviews.forEach {
      $0.layer.cornerRadius = self.frame.height / 2
      $0.layer.masksToBounds = true
      $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
  }
}

// MARK: - Private Methods
private extension MediumProgressBar {
  func setupUI() {
    self.backgroundColor = .gray200
    self.progressTintColor = .green400
    setPercentage(percent)
  }
  
  func setPercentage(_ percent: PhotiProgressPercent) {
    switch percent {
    case .percent20:
      self.setProgress(0.2, animated: true)
    case .percent40:
      self.setProgress(0.4, animated: true)
    case .percent60:
      self.setProgress(0.6, animated: true)
    case .percent80:
      self.setProgress(0.8, animated: true)
    case .percent100:
      self.setProgress(1.0, animated: true)
    case .percent0:
      self.setProgress(0.0, animated: true)
    }
  }
}
