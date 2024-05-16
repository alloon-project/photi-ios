//
//  CalendarHeaderView.swift
//  DesignSystem
//
//  Created by jung on 5/13/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class CalendarHeaderView: UIView {
  var text: String = "" {
    didSet {
      setLabel(text)
    }
  }
  
  var leftDisabled: Bool = false {
    didSet {
      self.leftImageView.tintColor = leftDisabled ? .gray200 : .gray500
    }
  }
  
  var rightDisabled: Bool = false {
    didSet {
      self.rightImageView.tintColor = rightDisabled ? .gray200 : .gray500
    }
  }
  
  // MARK: - UI Components
  // TODO: ICON 적용 이후 이미지 변경
  private let leftImageView: UIImageView = {
    let imageView = UIImageView()
    let image = UIImage(systemName: "chevron.left")!
    imageView.contentMode = .scaleAspectFill
    imageView.image = image.withAlignmentRectInsets(UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8))
    imageView.tintColor = .gray200
    
    return imageView
  }()
  
  private let rightImageView: UIImageView = {
    let imageView = UIImageView()
    let image = UIImage(systemName: "chevron.right")!
    imageView.contentMode = .scaleAspectFill
    imageView.image = image.withAlignmentRectInsets(UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8))
    imageView.tintColor = .gray500
    
    return imageView
  }()
  
  // TODO: Icon DS작업 후 변경 예정
  let closeButton: UIButton = {
    let button = UIButton()
    let image = UIImage(systemName: "xmark.circle.fill")!
    let resizeImage = image.resize(CGSize(width: 24, height: 24)).withTintColor(.gray200)
    
    button.setImage(resizeImage, for: .normal)
    button.layer.cornerRadius = 12
    
    return button
  }()
  
  private let label = UILabel()
  
  // MARK: - Initializers
  init(text: String = "") {
    self.text = text
    super.init(frame: .zero)
    
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension CalendarHeaderView {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    
    setLabel(text)
  }
  
  func setViewHierarchy() {
    addSubviews(leftImageView, label, rightImageView, closeButton)
  }
  
  func setConstraints() {
    label.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(116)
    }
    
    leftImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalTo(label.snp.leading).offset(-6)
    }
    
    rightImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(label.snp.trailing).offset(6)
    }
    
    closeButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(24)
      $0.leading.equalTo(rightImageView.snp.trailing).offset(43)
    }
  }
}

// MARK: - Private Methods
private extension CalendarHeaderView {
  func setLabel(_ text: String) {
    label.attributedText = text.attributedString(
      font: .heading3,
      color: .gray900,
      alignment: .center
    )
  }
}
