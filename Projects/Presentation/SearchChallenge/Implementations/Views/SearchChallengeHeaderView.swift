//
//  SearchChallengeHeaderView.swift
//  HomeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class SearchChallengeHeaderView: UIView {
  private let imageView = UIImageView()
  private let label = UILabel()
  
  init(image: UIImage, title: String) {
    super.init(frame: .zero)
    setupUI()
    imageView.image = image
    label.attributedText = title.attributedString(font: .heading4, color: .gray900)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension SearchChallengeHeaderView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(imageView, label)
  }
  
  func setConstraints() {
    imageView.snp.makeConstraints {
      $0.width.height.equalTo(20)
      $0.top.bottom.leading.equalToSuperview().inset(2)
    }
    
    label.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing).offset(8)
      $0.trailing.centerY.equalToSuperview()
    }
  }
}
