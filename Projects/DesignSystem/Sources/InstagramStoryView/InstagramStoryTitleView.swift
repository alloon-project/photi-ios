//
//  InstagramStoryTitleView.swift
//  DesignSystem
//
//  Created by jung on 8/8/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Core

final class InstagramStoryTitleView: UIView {
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let leftImageView = UIImageView(image: .closeCircleGreen)
  private let rightImageView = UIImageView(image: .closeCircleGreen)
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure
  func configure(with title: String) {
    print("title: \(title)")
    titleLabel.attributedText = title.attributedString(font: .heading3, color: .green700, alignment: .center)
  }
}

// MARK: - UI Methods
private extension InstagramStoryTitleView {
  func setupUI() {
    titleLabel.numberOfLines = 1
    titleLabel.textAlignment = .center
    layer.cornerRadius = 16
    layer.borderWidth = 6
    layer.borderColor = UIColor.green200.cgColor
 
    backgroundColor = .green0
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(titleLabel, leftImageView, rightImageView)
  }
  
  func setConstraints() {
    leftImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(8)
      $0.width.height.equalTo(12)
      $0.centerY.equalToSuperview()
    }
    
    rightImageView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(8)
      $0.width.height.equalTo(12)
      $0.centerY.equalToSuperview()
    }
  
    titleLabel.snp.makeConstraints {
      $0.height.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(29)
    }
  }
}
