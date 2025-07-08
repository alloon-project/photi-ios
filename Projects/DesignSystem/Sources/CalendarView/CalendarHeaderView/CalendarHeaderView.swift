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
      leftArrowButton.isEnabled = !leftDisabled
    }
  }
  
  var rightDisabled: Bool = false {
    didSet {
      rightArrowButton.isEnabled = !rightDisabled
    }
  }
  
  // MARK: - UI Components
  let leftArrowButton = {
    let button = UIButton()
    button.setImage(.chevronBackGray400, for: .disabled)
    button.setImage(.chevronBackGray700, for: .normal)
    return button
  }()
  
  let rightArrowButton = {
    let button = UIButton()
    button.setImage(.chevronForwardGray400, for: .disabled)
    button.setImage(.chevronForwardGray700, for: .normal)
    return button
  }()
  
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
    addSubviews(leftArrowButton, label, rightArrowButton, closeButton)
  }
  
  func setConstraints() {
    label.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(116)
    }
    
    leftArrowButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalTo(label.snp.leading).offset(-6)
    }
    
    rightArrowButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(label.snp.trailing).offset(6)
    }
    
    closeButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(24)
      $0.leading.equalTo(rightArrowButton.snp.trailing).offset(43)
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
