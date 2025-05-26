//
//  ChallengeTitleResultCardCell.swift
//  HomeImpl
//
//  Created by jung on 5/24/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit

final class ChallengeTitleResultCardCell: UICollectionViewCell {
  private let cardView = SearchChallengeCard()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with model: ResultChallengeCardPresentationModel) {
    cardView.configure(with: model)
  }
}

// MARK: - UI Methods
private extension ChallengeTitleResultCardCell {
  func setupUI() {
    contentView.addSubview(cardView)
    cardView.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
}
