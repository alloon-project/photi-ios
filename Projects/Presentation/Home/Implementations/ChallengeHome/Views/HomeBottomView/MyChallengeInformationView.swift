//
//  MyChallengeInformationView.swift
//  HomeImpl
//
//  Created by jung on 10/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import CoreUI
import DesignSystem

final class MyChallengeInformationView: UIView {
  let imageView = UIImageView()
  let label = UILabel()
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(image: UIImage, text: String) {
    imageView.image = image
    label.attributedText = text.attributedString(font: .caption1Bold, color: .gray600)
  }
}

// MARK: - UI Methods
private extension MyChallengeInformationView {
  func setupUI() {
    setViewHeirarchy()
    setConstraints()
  }
  
  func setViewHeirarchy() {
    addSubviews(imageView, label)
  }
  
  func setConstraints() {
    imageView.snp.makeConstraints {
      $0.top.leading.bottom.equalToSuperview()
      $0.width.height.equalTo(16)
    }
    
    label.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing).offset(6)
      $0.trailing.centerY.equalToSuperview()
    }
  }
}
