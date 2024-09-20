//
//  CreateChallengeContentView.swift
//  HomeImpl
//
//  Created by jung on 9/20/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class CreateChallengeContentView: UIView {
  private let label: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    
    return label
  }()
  
  private let imageView = UIImageView()
  
  init(text: String, image: UIImage) {
    super.init(frame: .zero)
    
    setupUI()
    
    label.attributedText = text.attributedString(font: .body2, color: .gray700)
    imageView.image = image
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension CreateChallengeContentView {
  func setupUI() {
    self.layer.cornerRadius = 12
    self.backgroundColor = .blue0
    setViewHeirarchy()
    setConstraints()
  }
  
  func setViewHeirarchy() {
    addSubviews(label, imageView)
  }
  
  func setConstraints() {
    label.snp.makeConstraints {
      $0.leading.trailing.top.equalToSuperview().inset(14)
    }
    
    imageView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview().inset(14)
    }
  }
}
