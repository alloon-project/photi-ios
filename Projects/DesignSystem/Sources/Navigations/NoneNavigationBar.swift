//
//  NoneNavigationBar.swift
//  DesignSystem
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

public final class NoneNavigationBar: PhotiNavigationBar {
  public enum RightBarButtonCount {
    case zero
    case one
    case two
  }
  // MARK: - Properties
  public override var mode: PhotiNavigationBar.Mode {
    didSet { configureButtonImage(rightButtonCount: buttonCount, for: mode) }
  }
  
  private let buttonCount: RightBarButtonCount
  
  // MARK: - UI Components
  fileprivate let backButton = PhotiNavigationButton(image: .chevronBackWhite)
  fileprivate lazy var shareButton = PhotiNavigationButton(image: .shareWhite)
  fileprivate lazy var optionButton = PhotiNavigationButton(image: .ellipsisVerticalWhite)
  
  // MARK: - Initializers
  public init(buttonCount: RightBarButtonCount, mode: Mode) {
    self.buttonCount = buttonCount
    super.init(mode: mode)
    
    setupUI(for: buttonCount, mode: mode)
  }
}

// MARK: - UI Methods
private extension NoneNavigationBar {
  func setupUI(for count: RightBarButtonCount, mode: Mode) {
    setViewHierarchy(for: count)
    setConstraints()
    configureButtonImage(rightButtonCount: count, for: mode)
  }
  
  func setViewHierarchy(for count: RightBarButtonCount) {
    addSubview(backButton)
    
    switch count {
      case .one: rightItems = [optionButton]
      case .two: rightItems = [shareButton, optionButton]
      default: break
    }
  }
  
  func setConstraints() {
    backButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(13)
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
private extension NoneNavigationBar {
  func configureWhiteModeButtonImage(rightButtonCount count: RightBarButtonCount) {
    backButton.configure(with: .chevronBackWhite)
    switch count {
      case .one:
        optionButton.configure(with: .ellipsisVerticalWhite)
      case .two:
        optionButton.configure(with: .ellipsisVerticalWhite)
        shareButton.configure(with: .shareWhite)
      default: break
    }
  }
  
  func configureDarkModeButtonImage(rightButtonCount count: RightBarButtonCount) {
    backButton.configure(with: .chevronBackGray700)
    switch count {
      case .one:
        optionButton.configure(with: .ellipsisVerticalGray700)
      case .two:
        optionButton.configure(with: .ellipsisVerticalGray700)
        shareButton.configure(with: .shareGray700)
      default: break
    }
  }
}

public extension Reactive where Base: NoneNavigationBar {
  var didTapBackButton: ControlEvent<Void> {
    return .init(events: base.backButton.rx.tap)
  }
  
  var didTapOptionButton: ControlEvent<Void> {
    return .init(events: base.optionButton.rx.tap)
  }
  
  var didTapShareButton: ControlEvent<Void> {
    return .init(events: base.shareButton.rx.tap)
  }
}
