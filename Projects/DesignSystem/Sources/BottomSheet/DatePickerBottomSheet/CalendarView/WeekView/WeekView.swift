//
//  WeekView.swift
//  DesignSystem
//
//  Created by jung on 5/13/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class WeekView: UIStackView {
  private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
  
  // MARK: - Initalizers
  init(spacing: CGFloat = 0) {
    super.init(frame: .zero)
    axis = .horizontal
    alignment = .center
    distribution = .fillEqually
    self.spacing = spacing
    setupUI()
  }
  
  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension WeekView {
  func setupUI() {
    setViewHierarchy()
  }
  
  func setViewHierarchy() {
    daysOfWeek.forEach { addArrangedSubview(label($0)) }
    
    self.arrangedSubviews.forEach {
      $0.snp.makeConstraints {
        $0.width.equalTo(14)
      }
    }
  }
}

// MARK: - Private Methods
private extension WeekView {
  func label(_ text: String) -> UILabel {
    let label = UILabel()
    
    label.attributedText = text.attributedString(
      font: .body2,
      color: .gray600,
      alignment: .center
    )

    return label
  }
}
