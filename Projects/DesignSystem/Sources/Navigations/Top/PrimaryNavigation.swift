//
//  PrimaryNavigationView.swift
//  DesignSystem
//
//  Created by 임우섭 on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

import Core

import SnapKit

/// 앱 상단에 삽입되는 PrimaryNavigationView 입니다.
public final class PrimaryNavigationView: UIView {
  /// text의 타입을 나타냅니다
  public let textType: PrimaryNavigationTextType
  /// icon의 타입을 나타냅니다.
  public let iconType: PrimaryNavigationIconType
  public var leftImageView = UIImageView(image:
                                          UIImage(resource: .leftBackButton))
  /// 타이틀 Label입니다. textType에 따라 유/무, 위치가 변경됩니다.
  public var titleLabel = {
    let label = UILabel()
    label.textColor = .title
    label.font = .body1Bold
    label.textAlignment = .center
    return label
  }()
  public let rightImageView = UIImageView()
  
  // MARK: - Initalizers
  public init(
    textType: PrimaryNavigationTextType, 
    iconType: PrimaryNavigationIconType,
    titleText: String?
  ) {
    self.textType = textType
    self.iconType = iconType
    self.titleLabel.text = titleText
    super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    setupUI()
  }
  
  @available(*, unavailable)
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension PrimaryNavigationView {
  // MARK: - Setup UI
  func setupUI() {
    makeTextType()
    makeIconType()
  }
  
  // MARK: - Private Methods
  /// TextType에 맞추어 좌/우 버튼 종류 & 타이틀의 배치를 결정합니다.
  func makeTextType() {
    switch self.textType {
    case .none:
      makeNone()
    case .left:
      makeLeft()
    case .center:
      makeCenter()
    }
  }
  
  func makeNone() {
    self.addSubview(leftImageView)
    leftImageView.snp.makeConstraints {
      $0.width.height.equalTo(32)
      $0.top.equalToSuperview().offset(12)
      $0.leading.equalToSuperview().offset(13)
    }
  }
  
  func makeLeft() {
    self.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-56)
    }
    titleLabel.textAlignment = .left
    titleLabel.font = .heading1
  }
  
  func makeCenter() {
    self.addSubviews(leftImageView, titleLabel)
    leftImageView.snp.makeConstraints {
      $0.width.height.equalTo(32)
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(13)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(leftImageView.snp.trailing).offset(8)
      $0.trailing.equalToSuperview().offset(-58)
    }
  }
  /// Icon Type 에 맞추어 우측 버튼의 유무를 결정합니다.
  func makeIconType() {
    switch self.iconType {
    case .one:
      makeOne()
    case .two:
      makeTwo()
    }
  }
  
  func makeOne() {
    // 아직 내용 없음
  }
  
  func makeTwo() {
    switch self.textType {
    case .none:
      rightImageView.image = UIImage(resource: .ellipsisVertical)
    case .left:
      rightImageView.image = UIImage(resource: .iconSearch)
    case .center:
      rightImageView.image = UIImage(resource: .ellipsisVertical)
    }
    
    self.addSubview(rightImageView)
    rightImageView.snp.makeConstraints {
      $0.width.height.equalTo(32)
      $0.top.equalToSuperview().offset(12)
      $0.trailing.equalToSuperview().offset(-13)
    }
  }
}
