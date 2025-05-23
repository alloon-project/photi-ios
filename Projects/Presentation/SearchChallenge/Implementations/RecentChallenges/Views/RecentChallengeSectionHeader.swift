//
//  RecentChallengeSectionHeader.swift
//  Presentation
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

final class RecentChallengeSectionHeader: UICollectionReusableView {
  // MARK: - UI Components
  private let headerView = SearchChallengeHeaderView(image: .flashGray700, title: "모든 챌린지")
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension RecentChallengeSectionHeader {
  func setupUI() {
    backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubview(headerView)
  }
  
  func setConstraints() {
    headerView.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}
