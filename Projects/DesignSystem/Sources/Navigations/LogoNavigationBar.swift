//
//  LogoNavigationBar.swift
//  DesignSystem
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit

public final class LogoNavigationBar: PhotiNavigationBar {
  public override var mode: PhotiNavigationBar.Mode {
    didSet { configureUI(for: mode) }
  }
  
  private let logoImageView  = UIImageView()
  
  public override init(mode: PhotiNavigationBar.Mode) {
    super.init(mode: mode)
    
    setupUI()
  }
}

// MARK: - UI Methods
private extension LogoNavigationBar {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    configureUI(for: mode)
  }
  
  func setViewHierarchy() {
    addSubview(logoImageView)
  }
  
  func setConstraints() {
    logoImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(24)
    }
  }
  
  func configureUI(for mode: PhotiNavigationBar.Mode) {
    switch mode {
      case .dark:
        logoImageView.image = .logoLettersBlue
      case .white:
        logoImageView.image = .logoLettersWhite
    }
  }
}
