//
//  ChallengeGoalView.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import DesignSystem

final class ChallengeGoalView: UIView, ChallengeInformationPresentable {
  enum Constants {
    static let flashIconSize: CGFloat = 65
    static let rotateFlashIconSize: CGFloat = 40
  }
  
  // MARK: UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "목표".attributedString(
      font: .caption1Bold,
      color: .blue500
    )
    return label
  }()
  
  private let goalLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    return label
  }()
  private let flashImageView: UIImageView = {
    let imageView = UIImageView(image: .flashFilledLightBlue)
    
    return imageView
  }()
  
  private let rotateFlashImageView: UIImageView = {
    let imageView = UIImageView(image: .flashFilledLightBlue)
    let radian: CGFloat = 5 * .pi / 100
    imageView.transform = imageView.transform.rotated(by: -radian)

    return imageView
  }()

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
  func configure(goal: String) {
    goalLabel.attributedText = goal.attributedString(
      font: .body2,
      color: .gray800
    )
  }
}

// MARK: - UI Methods
private extension ChallengeGoalView {
  func setupUI() {
    configureBackground(color: .blue0, borderColor: .blue100)
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(titleLabel, goalLabel)
    addSubviews(flashImageView, rotateFlashImageView)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(14)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    goalLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    flashImageView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(8)
      $0.bottom.equalToSuperview().inset(16)
      $0.width.height.equalTo(Constants.flashIconSize)
    }
    
    rotateFlashImageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(252)
      $0.leading.equalToSuperview().offset(95)
      $0.width.height.equalTo(Constants.rotateFlashIconSize)
    }
  }
}
