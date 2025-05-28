//
//  HashTagResultHashTagCell.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

final class HashTagResultHashTagCell: UICollectionViewCell {
  private let chip = TextChip(type: .darkGray, size: .small)
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with text: String) {
    chip.text = text
  }
}

// MARK: - UI Methods
private extension HashTagResultHashTagCell {
  func setupUI() {
    contentView.addSubview(chip)
    chip.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}
