//
//  PhotiNavigationBar.swift
//  DesignSystem
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

open class PhotiNavigationBar: UIView {
  public enum Mode {
    case dark
    case white
  }
  
  public var mode: Mode
  public var rightItems: [UIView] = [] {
    didSet {
      oldValue.forEach { rightStackView.removeArrangedSubview($0) }
      rightItems.forEach { rightStackView.addArrangedSubview($0) }
      rightStackView.sizeToFit()
    }
  }
  
  // MARK: - UI Components
  private let rightStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 16
    stackView.distribution = .fillProportionally
    stackView.alignment = .center
    
    return stackView
  }()
  
  // MARK: - Initializers
  public init(mode: Mode) {
    self.mode = mode
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension PhotiNavigationBar {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(rightStackView)
  }
  
  func setConstraints() {
    rightStackView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-11)
    }
  }
}
