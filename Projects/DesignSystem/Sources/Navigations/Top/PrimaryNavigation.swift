//
//  PrimaryNavigationView.swift
//  DesignSystem
//
//  Created by 임우섭 on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

/// 앱 상단에 삽입되는 PrimaryNavigationView 입니다.
///
/// default Color type은 dark 입니다.
public final class PrimaryNavigationView: UIView {
  public var title: String = "" {
    didSet {
      setTitleLabel(title)
    }
  }
  
  /// text의 타입을 나타냅니다
  public let textType: PrimaryNavigationTextType
  /// icon의 타입을 나타냅니다.
  public let iconType: PrimaryNavigationIconType
  /// 컴포넌트의 컬러 타입을 나타냅니다. (default : dark)
  public let colorType: PrimaryNavigationColorType
  public let leftImageView = UIImageView(image:
                                          UIImage(resource: .leftBackButtonDark))
  /// 타이틀 Label입니다. textType에 따라 유/무, 위치가 변경됩니다.
  private let titleLabel = UILabel()
  public let rightImageView = UIImageView()
  
  // MARK: - Initalizers
  public init(
    textType: PrimaryNavigationTextType, 
    iconType: PrimaryNavigationIconType,
    colorType: PrimaryNavigationColorType = .dark,
    titleText: String?
  ) {
    self.textType = textType
    self.iconType = iconType
    self.colorType = colorType
    super.init(frame: .zero)
   
    if let titleText = titleText { self.title = titleText }
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
    makeColorType()
    
    if !title.isEmpty { setTitleLabel(title) }
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
      $0.width.height.equalTo(24)
      $0.centerX.equalToSuperview()
      $0.leading.equalToSuperview().offset(13)
    }
  }
  
  func makeLeft() {
    self.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(24)
    }
  }
  
  func makeCenter() {
    self.addSubviews(leftImageView, titleLabel)
    leftImageView.snp.makeConstraints {
      $0.width.height.equalTo(24)
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(13)
    }
    
    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  /// Icon Type 에 맞추어 우측 버튼의 유무를 결정합니다.
  func makeIconType() {
    switch self.iconType {
    case .one:
      break
    case .two:
      makeTwo()
    }
  }
  
  func makeTwo() {
    switch self.textType {
    case .none, .center:
      switch colorType {
      case .light:
        rightImageView.image = UIImage(resource: .ellipsisVerticalLight)
      case .dark:
        rightImageView.image = UIImage(resource: .ellipsisVerticalDark)
      }
    case .left:
      switch colorType {
      case .light:
        rightImageView.image = UIImage(resource: .iconSearchLight)
      case .dark:
        rightImageView.image = UIImage(resource: .iconSearchDark)
      }
    }
    
    self.addSubview(rightImageView)
    rightImageView.snp.makeConstraints {
      $0.width.height.equalTo(24)
      $0.top.equalToSuperview().offset(12)
      $0.trailing.equalToSuperview().offset(-13)
    }
  }
  
  /// Color Type 에 맞추어 색상을 결정합니다.
  func makeColorType() {
    switch self.colorType {
    case .light:
      leftImageView.image = UIImage(resource: .leftBackButtonLight)
    case .dark:
      leftImageView.image = UIImage(resource: .leftBackButtonDark)
    }
  }
  
  func setTitleLabel(_ text: String) {
    titleLabel.attributedText = text.attributedString(
      font: font(for: textType),
      color: textColor(for: colorType)
    )
  }
  
  func textColor(for type: PrimaryNavigationColorType) -> UIColor {
    switch type {
      case .dark:
        return .gray900
      case .light:
        return .alloonWhite
    }
  }
  
  func font(for type: PrimaryNavigationTextType) -> UIFont {
    switch type {
      case .none, .left:
        return .heading1
      case .center:
        return .body1Bold
    }
  }
}
