//
//  HashTagCell.swift
//  HomeImpl
//
//  Created by jung on 9/20/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class HashTagCell: UICollectionViewCell {
  private let textChip = TextChip(type: .gray, size: .medium)
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(text: String) {
    textChip.text = text
  }
}

// MARK: - UI Methods
private extension HashTagCell {
  func setupUI() {
    contentView.addSubview(textChip)
    textChip.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}
