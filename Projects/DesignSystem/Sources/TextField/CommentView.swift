//
//  CommentView.swift
//  DesignSystem
//
//  Created by jung on 5/7/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

/// CommentView의 type을 정의합니다.
public enum CommentViewType {
  case condition
  case warning
}

/// TextField가 `helper`type일 때, 정의되는 comment입니다.
final public class CommentView: UIView {
  public let type: CommentViewType
  
  /// CommentView를 활성화 여부를 결정합니다.
  public var isActivate: Bool {
    didSet {
      setTextAndIconColor(isActivate ? activateColor : deActivateColor)
    }
  }
  
  /// CommentView가 활성화되었을 때, `color`를 정의합니다.
  public var activateColor: UIColor {
    switch type {
      case .condition:
        return .blue400
      case .warning:
        return .red400
    }
  }
  
  /// CommentView가 비활성화되었을 때, `color`를 정의합니다.
  public var deActivateColor: UIColor {
    switch type {
      case .condition:
        return .gray400
      case .warning:
        return .clear
    }
  }
  
  /// CommentView의 text를 정의합니다.
  public var text: String {
    didSet {
      setLabel(text, isActivate: isActivate)
    }
  }
  
  /// CommentView의 icon를 정의합니다.
  public var icon: UIImage {
    didSet {
      setIconView(icon, isActivate: isActivate)
    }
  }
  
  public var iconSize: CGSize = CGSize(width: 12, height: 12) {
    didSet {
      setIconView(icon, isActivate: isActivate)
    }
  }
  
  // MARK: - UI Components
  private let label = UILabel()
  private let imageView = UIImageView()
  
  // MARK: - Initalizers
  public init(
    _ type: CommentViewType,
    text: String,
    icon: UIImage,
    isActivate: Bool = false
  ) {
    self.type = type
    self.text = text
    self.icon = icon
    self.isActivate = isActivate
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension CommentView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    
    setLabel(text, isActivate: isActivate)
    setIconView(icon, isActivate: isActivate)
  }
  
  func setViewHierarchy() {
    self.addSubviews(label, imageView)
  }
  
  func setConstraints() {
    imageView.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview()
      $0.height.width.equalTo(12)
    }
    label.snp.makeConstraints {
      $0.centerY.equalTo(imageView)
      $0.trailing.equalToSuperview()
      $0.leading.equalTo(imageView.snp.trailing).offset(6)
    }
  }
}

// MARK: - internal Methods
internal extension CommentView {
  func setLabel(_ text: String, isActivate: Bool) {
    label.attributedText = text.attributedString(
      font: .caption1,
      color: isActivate ? activateColor : deActivateColor
    )
  }
  
  func setIconView(_ image: UIImage, isActivate: Bool) { 
    let resizeImage = image.resize(iconSize)
      .withTintColor(isActivate ? activateColor : deActivateColor)
    self.imageView.image = resizeImage
  }
  
  func setTextAndIconColor(_ color: UIColor) {
    label.attributedText = label.attributedText?.setColor(color)
    imageView.image = imageView.image?.withTintColor(color)
  }
}
