//
//  ChallengeTitleView.swift
//  HomeImpl
//
//  Created by jung on 10/7/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem
import Core

final class ChallengeTitleView: UIView {
  typealias ModelType = MyChallengeFeedPresentationModel.ModelType
  // MARK: - UI Components
  private let titleLabel = UILabel()
  private let imageView = UIImageView()
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Method
  func configure(title: String, type: ModelType) {
    configureLabel(text: title)
    configureBackgounrd(type: type)
    configureImageView(type: type)
  }
}

// MARK: - UI Methods
private extension ChallengeTitleView {
  func setupUI() {
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

// MARK: - Private Methods
private extension ChallengeTitleView {
  func configureLabel(text: String) {
    titleLabel.attributedText = text.attributedString(
      font: .body1Bold,
      color: .photiWhite
    )
  }

  func configureBackgounrd(type: ModelType) {
    switch type {
      case .proof:
        self.backgroundColor = .green400
      case .didNotProof:
        self.backgroundColor = .blue400
    }
  }
  
  func configureImageView(type: ModelType) {
    switch type {
      case .proof:
        self.imageView.image = .cloverGreen
      case .didNotProof:
        self.imageView.image = .timeLightBlue
    }
  }
}
