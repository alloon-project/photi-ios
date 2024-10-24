//
//  LeftTitleNavigationBar.swift
//  DesignSystem
//
//  Created by jung on 10/24/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Core

public final class LeftTitleNavigationBar: PhotiNavigationBar {
  public enum RightBarButtonCount {
    case zero
    case one
  }
  // MARK: - Properties
  public override var mode: PhotiNavigationBar.Mode {
    didSet {
      configureButtonImage(rightButtonCount: buttonCount, for: mode)
      configureTitleLabel(title, for: mode)
    }
  }
  
  private let buttonCount: RightBarButtonCount
  private let title: String

  // MARK: - UI Components
  private let titleLabel = UILabel()
  fileprivate lazy var searchButton = PhotiNavigationButton(image: .searchWhite)
  
  // MARK: - Initializers
  public init(rightButtonCount: RightBarButtonCount, mode: Mode, title: String) {
    self.buttonCount = rightButtonCount
    self.title = title
    super.init(mode: mode)
    
    setupUI(for: buttonCount, mode: mode)
  }
}

// MARK: - UI Methods
private extension LeftTitleNavigationBar {
  func setupUI(for count: RightBarButtonCount, mode: Mode) {
    setViewHierarchy(for: count)
    setConstraints()
    configureButtonImage(rightButtonCount: count, for: mode)
    configureTitleLabel(title, for: mode)
  }
  
  func setViewHierarchy(for count: RightBarButtonCount) {
    addSubviews(titleLabel)
    
    if count == .one {
      rightItems = [searchButton]
    }
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.centerY.equalToSuperview()
    }
  }
  
  func configureButtonImage(rightButtonCount count: RightBarButtonCount, for mode: Mode) {
    switch mode {
      case .dark:
        configureDarkModeButtonImage(rightButtonCount: count)
      case .white:
        configureWhiteModeButtonImage(rightButtonCount: count)
    }
  }
}

// MARK: - Private Methods
private extension LeftTitleNavigationBar {
  func configureTitleLabel(_ text: String, for mode: Mode) {
    titleLabel.attributedText = title.attributedString(
      font: .heading1,
      color: titleLabelColor(for: mode)
    )
  }
  
  func configureWhiteModeButtonImage(rightButtonCount count: RightBarButtonCount) {
    guard count == .one else { return }

    searchButton.configure(with: .searchWhite)
  }
  
  func configureDarkModeButtonImage(rightButtonCount count: RightBarButtonCount) {
    guard count == .one else { return }
    
    searchButton.configure(with: .searchGray700)
  }
  
  func titleLabelColor(for mode: Mode) -> UIColor {
    switch mode {
      case .dark:
        return .gray900
      case .white:
        return .white
    }
  }
}

public extension Reactive where Base: LeftTitleNavigationBar {
  var didTapSearchButton: ControlEvent<Void> {
    return .init(events: base.searchButton.rx.tap)
  }
}
