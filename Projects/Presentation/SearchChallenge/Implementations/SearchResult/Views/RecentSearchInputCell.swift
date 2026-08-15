//
//  RecentSearchInputCell.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import UIKit
import SnapKit
import DesignSystem

final class RecentSearchInputCell: UICollectionViewCell {
  fileprivate let chip = IconChip(icon: .closeGray700, type: .line, size: .large)

  var didTapDeleteButton: AnyPublisher<Void, Never> {
    chip.didTapIcon
  }

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
private extension RecentSearchInputCell {
  func setupUI() {
    contentView.addSubview(chip)
    chip.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}
