//
//  ChallengeRuleHeaderView.swift
//  Presentation
//
//  Created by 임우섭 on 4/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

final class ChallengeRuleHeaderView: UICollectionReusableView {
  // MARK: - UI Components
  private let dotImageView = UIImageView(image: .divider)
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension ChallengeRuleHeaderView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubview(dotImageView)
  }
  
  func setConstraints() {
    dotImageView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
      $0.centerY.equalToSuperview()
    }
  }
}
