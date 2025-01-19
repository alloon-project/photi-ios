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
      leftImageView.image = leftDisabled ? .chevronBackGray400 : .chevronBackGray700
    }
  }
  
  var rightDisabled: Bool = false {
    didSet {
      rightImageView.image = rightDisabled ? .chevronForwardGray400 : .chevronForwardGray700
    }
  }
  
  // MARK: - UI Components
  private let leftImageView = UIImageView(image: .chevronBackGray400)
  private let rightImageView = UIImageView(image: .chevronForwardGray700)
  
  let closeButton: UIButton = {
    let button = UIButton()
    button.setImage(.closeCircleLight, for: .normal)
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
