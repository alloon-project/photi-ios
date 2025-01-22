//
//  DescriptionView.swift
//  HomeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Core
import DesignSystem

final class DescriptionView: UIView {
  enum DescriptionType {
    case goal, duration
  }
  
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let subTitleLabel = UILabel()
  
  // MARK: - Initializers
  init(type: DescriptionType) {
    super.init(frame: .zero)
    
    setupUI(type: type)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(subTitle: String) {
    subTitleLabel.attributedText = subTitle.attributedString(
      font: .body2,
      color: .gray600
    )
  }
}

// MARK: - UI Methods
private extension DescriptionView {
  func setupUI(type: DescriptionType) {
    let title = type == .goal ? "목표" : "기간"
    
    titleLabel.attributedText = title.attributedString(
      font: .body1Bold,
      color: .gray900
    )
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(titleLabel, subTitleLabel)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.leading.top.equalToSuperview()
    }
    
    subTitleLabel.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(20)
    }
  }
}
