//
//  FeedsLoadingFooterView.swift
//  ChallengeImpl
//
//  Created by jung on 2/24/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit

final class FeedsLoadingFooterView: UICollectionReusableView {
  private let activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.hidesWhenStopped = true
    return indicator
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  func startLoading() {
    activityIndicator.startAnimating()
  }
  
  func stopLoading() {
    activityIndicator.stopAnimating()
  }
}
