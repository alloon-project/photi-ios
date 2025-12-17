//
//  FeedCollectionHeaderView.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import CoreUI
import DesignSystem

final class FeedsHeaderView: UICollectionReusableView {
  enum HeaderType {
    case none
    case didNotProve(String)
    case didProve
  }

  private var headerType: HeaderType = .none
  
  // MARK: - UI Components
  private let dateLabel = UILabel()
  private let proveTimeView = UIView()
  private let proveTimeImageView = UIImageView()
  private let proveTimeLabel = UILabel()
  
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
  func configure(date: String, type: HeaderType = .none) {
    setDateText(date)
    configureProveTime(with: type)
  }
  
  func configure(type: HeaderType) {
    configureProveTime(with: type)
  }
}

// MARK: - UI Methods
private extension FeedsHeaderView {
  func setupUI() {
    backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(dateLabel, proveTimeView)
    proveTimeView.addSubviews(proveTimeImageView, proveTimeLabel)
  }
  
  func setConstraints() {
    dateLabel.snp.makeConstraints {
      $0.centerY.leading.equalToSuperview()
    }
    
    proveTimeView.snp.makeConstraints {
      $0.centerY.trailing.equalToSuperview()
    }
    
    proveTimeImageView.snp.makeConstraints {
      $0.top.bottom.leading.equalToSuperview()
      $0.width.height.equalTo(18)
    }
    
    proveTimeLabel.snp.makeConstraints {
      $0.centerY.trailing.equalToSuperview()
      $0.leading.equalTo(proveTimeImageView.snp.trailing).offset(4)
    }
  }
}

// MARK: - Private Methods
private extension FeedsHeaderView {
  func configureProveTime(with type: HeaderType) {
    switch type {
      case .none:
        proveTimeView.isHidden = true
      case .didProve:
        proveTimeView.isHidden = false
        setProveTimeText("인증완료", color: .green500)
        setProveTimeImage(.timeGreen)

      case let .didNotProve(proveTime):
        proveTimeView.isHidden = false
        setProveTimeText(proveTime, color: .blue500)
        setProveTimeImage(.timeBlue)
    }
  }
  
  func setDateText(_ text: String) {
    dateLabel.attributedText = text.attributedString(
      font: .body1Bold,
      color: .init(red: 0.27, green: 0.27, blue: 0.27, alpha: 1)
    )
  }
  
  func setProveTimeImage(_ image: UIImage) {
    proveTimeImageView.image = image
  }
  
  func setProveTimeText(_ text: String, color: UIColor) {
    proveTimeLabel.attributedText = text.attributedString(font: .caption1Bold, color: color)
  }
}
