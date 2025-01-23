//
//  ParticipantGoalView.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class ParticipantGoalView: UIView {
  private let emptyGoalText = "목표를 생각 중이에요"
  private let emptyGoalTextColor: UIColor = .gray400
  private let goalTextColor: UIColor = .gray600
  
  private var goalText: String = ""
  
  // MARK: - UI Components
  private let imageView = UIImageView(image: .challengeParticipantGoal)
  private let goalLabel = UILabel()
  
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
  func configure(goalText: String) {
    let text = goalText.isEmpty ? emptyGoalText : goalText
    let textColor = goalText.isEmpty ? emptyGoalTextColor : goalTextColor
    
    goalLabel.attributedText = text.attributedString(
      font: .body2Bold,
      color: textColor
    )
  }
}

// MARK: - UIMethods
private extension ParticipantGoalView {
  func setupUI() {
    setViewHeirarchy()
    setConstraints()
  }
  
  func setViewHeirarchy() {
    addSubviews(imageView, goalLabel)
  }
  
  func setConstraints() {
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    goalLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().inset(24)
      $0.centerY.equalToSuperview()
    }
  }
}
