//
//  TitleNavigationBar.swift
//  DesignSystem
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Core

public final class TitleNavigationBar: PhotiNavigationBar {
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
  fileprivate let backButton = PhotiNavigationButton(image: .chevronBackWhite)
  fileprivate lazy var optionButton = PhotiNavigationButton(image: .ellipsisVerticalWhite)
  
  // MARK: - Initializers
  public init(rightButtonCount: RightBarButtonCount, mode: Mode, title: String) {
    self.buttonCount = rightButtonCount
    self.title = title
    super.init(mode: mode)
    
    setupUI(for: buttonCount, mode: mode)
  }
}

// MARK: - UI Methods
private extension TitleNavigationBar {
  func setupUI(for count: RightBarButtonCount, mode: Mode) {
    setViewHierarchy(for: count)
    setConstraints()
    configureButtonImage(rightButtonCount: count, for: mode)
    configureTitleLabel(title, for: mode)
  }
  
  func setViewHierarchy(for count: RightBarButtonCount) {
    addSubviews(backButton, titleLabel)
    
    if count == .one {
      rightItems = [optionButton]
    }
  }
  
  func setConstraints() {
    backButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(13)
    }
    
    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
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
private extension TitleNavigationBar {
  func configureTitleLabel(_ text: String, for mode: Mode) {
    titleLabel.attributedText = title.attributedString(
      font: .body1Bold,
      color: titleLabelColor(for: mode)
    )
  }
  
  func configureWhiteModeButtonImage(rightButtonCount count: RightBarButtonCount) {
    backButton.configure(with: .chevronBackWhite)
    if count == .one {
      optionButton.configure(with: .ellipsisVerticalWhite)
    }
  }
  
  func configureDarkModeButtonImage(rightButtonCount count: RightBarButtonCount) {
    backButton.configure(with: .chevronBackGray700)
    if count == .one {
      optionButton.configure(with: .ellipsisVerticalGray700)
    }
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

public extension Reactive where Base: TitleNavigationBar {
  var didTapBackButton: ControlEvent<Void> {
    return .init(events: base.backButton.rx.tap)
  }
  
  var didTapOptionButton: ControlEvent<Void> {
    return .init(events: base.optionButton.rx.tap)
  }
}
