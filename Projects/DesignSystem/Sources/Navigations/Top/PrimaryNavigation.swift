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

//
public final class PrimaryNavigationView: UIView {
  public let textType: PrimaryNavigationTextType
  public let iconType: PrimaryNavigationIconType
  public var leftImageView = UIImageView(image:
                                          UIImage(systemName: "chevron.left")?
                                          .withTintColor(.white, renderingMode: .alwaysOriginal))
  public var titleLabel = {
    let label = UILabel()
    label.textColor = .gray900
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
      rightImageView.image = UIImage(systemName: "magnifyingglass")
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
