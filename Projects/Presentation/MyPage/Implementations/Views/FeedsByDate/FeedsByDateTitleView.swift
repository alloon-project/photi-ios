//
//  FeedsByDateTitleView.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem
import CoreUI

final class FeedsByDateTitleView: UIView {
  var title: String = "" {
    didSet {
      titleLabel.attributedText = title.attributedString(
        font: .body1Bold,
        color: .photiWhite
      )
    }
  }
  
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let imageView = UIImageView(image: .cloverGreen)
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension FeedsByDateTitleView {
  func setupUI() {
    backgroundColor = .green400
    layer.cornerRadius = 8
    clipsToBounds = true
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(titleLabel, imageView)
  }
    
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview().inset(14)
    }
    
    imageView.snp.makeConstraints {
      $0.top.equalTo(12)
      $0.trailing.bottom.equalToSuperview().offset(2)
      $0.width.equalTo(imageView.snp.height)
    }
  }
}
