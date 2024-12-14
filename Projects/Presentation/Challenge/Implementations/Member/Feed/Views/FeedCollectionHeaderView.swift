//
//  FeedCollectionHeaderView.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class FeedCollectionHeaderView: UICollectionReusableView {
  enum DeadLineTextType {
    case none
    case didNotProof(deadLine: String)
    case didProof
  }
  
  private var deadLineTextType: DeadLineTextType = .none
  
  // MARK: - UI Components
  private let dateLabel = UILabel()
  private let deadLineView = UIView()
  private let deadLineImageView = UIImageView()
  private let deadLineLabel = UILabel()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func configure(date: String, type: DeadLineTextType) {
    setDateText(date)
    configureDeadLine(with: type)
  }
}

// MARK: - UI Methods
private extension FeedCollectionHeaderView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(dateLabel, deadLineView)
    deadLineView.addSubviews(deadLineImageView, deadLineLabel)
  }
  
  func setConstraints() {
    dateLabel.snp.makeConstraints {
      $0.centerY.leading.equalToSuperview()
    }
    
    deadLineView.snp.makeConstraints {
      $0.centerY.trailing.equalToSuperview()
    }
    
    deadLineImageView.snp.makeConstraints {
      $0.top.bottom.leading.equalToSuperview()
      $0.width.height.equalTo(18)
    }
    
    deadLineLabel.snp.makeConstraints {
      $0.centerY.trailing.equalToSuperview()
      $0.leading.equalTo(deadLineImageView.snp.trailing).offset(4)
    }
  }
}

// MARK: - Private Methods
private extension FeedCollectionHeaderView {
  func configureDeadLine(with type: DeadLineTextType) {
    switch type {
      case .none:
        deadLineView.isHidden = true
      case .didProof:
        deadLineView.isHidden = false
        setDeadLineText("인증완료", color: .green500)
        setDeadLineImage(.timeGreen)

      case let .didNotProof(deadLine):
        deadLineView.isHidden = false
        setDeadLineText(deadLine, color: .blue500)
        setDeadLineImage(.timeBlue)
    }
  }
  
  func setDateText(_ text: String) {
    dateLabel.attributedText = text.attributedString(
      font: .body1Bold,
      color: .init(red: 0.27, green: 0.27, blue: 0.27, alpha: 1)
    )
  }
  
  func setDeadLineImage(_ image: UIImage) {
    deadLineImageView.image = image
  }
  
  func setDeadLineText(_ text: String, color: UIColor) {
    deadLineLabel.attributedText = text.attributedString(font: .caption1Bold, color: color)
  }
}
