//
//  SearchChallengeHashTagCell.swift
//  HomeImpl
//
//  Created by jung on 5/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

final class SearchChallengeHashTagCell: UICollectionViewCell {
  var isSelectedCell: Bool = false {
    didSet { chip.type = isSelectedCell ? .blue : .line }
  }
  private let chip = TextChip(type: .line, size: .large)
  
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
private extension SearchChallengeHashTagCell {
  func setupUI() {
    contentView.addSubview(chip)
    chip.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}
