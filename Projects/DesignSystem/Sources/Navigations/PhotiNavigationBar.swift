//
//  PhotiNavigationBar.swift
//  DesignSystem
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Combine
import SnapKit
import Core

public final class PhotiNavigationBar: UIView {
  public enum LeftViewType {
    case logo
    case title(String)
    case backButton
  }

  public enum DisplayMode {
    case dark
    case white
  }
  
  // MARK: - Properties
  public var didTapBackButton: AnyPublisher<Void, Never> { backButton.tap().eraseToAnyPublisher() }
  
  public var displayMode: DisplayMode {
    didSet {
      configureLeftView(for: leftViewType)
      configureRightView(for: displayMode)
      configureTitle(title)
    }
  }
  public let leftViewType: LeftViewType
  public var title: String {
    didSet {
      configureTitle(title)
    }
  }
  public var rightItems: [PhotiNavigationButton] {
    didSet {
      oldValue.forEach { rightStackView.removeArrangedSubview($0) }
      configureRightItems(rightItems)
    }
  }
  private var leftViewLeadingInset: CGFloat {
    switch leftViewType {
      case .logo, .title: return 23
      case .backButton: return 11
    }
  }
  private var leftLogoImage: UIImage {
    switch displayMode {
      case .dark: return .logoLettersBlue
      case .white: return .logoLettersWhite
    }
  }
  private var leftBackButtonImage: UIImage {
    switch displayMode {
      case .dark: return .chevronBackGray700
      case .white: return .chevronBackWhite
    }
  }
  private var labelColor: UIColor {
    switch displayMode {
      case .dark: return .gray900
      case .white: return .white
    }
  }
  private var rightButtonImageColor: UIColor {
    switch displayMode {
      case .dark: return .gray700
      case .white: return .white
    }
  }
  private var leftView: UIView {
    switch leftViewType {
      case .logo: return logoImageView
      case .title: return leftTitleLabel
      case .backButton: return backButton
    }
  }
  
  // MARK: - UI Components
  private let leftContentView = UIView()
  private let titleLabel = UILabel()
  private let rightStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 16
    stackView.distribution = .fillProportionally
    stackView.alignment = .center
    
    return stackView
  }()
  
  private lazy var leftTitleLabel = UILabel()
  private lazy var logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .center
    
    return imageView
  }()
  
  private lazy var backButton = PhotiNavigationButton(image: .chevronBackWhite)
  
  // MARK: - Initializers
  public init(
    leftView: LeftViewType,
    title: String,
    rightItems: [PhotiNavigationButton],
    displayMode: DisplayMode
  ) {
    self.displayMode = displayMode
    self.rightItems = rightItems
    self.leftViewType = leftView
    self.title = title
    super.init(frame: .zero)
    setupUI()
  }
  
  public convenience init(
    leftView: LeftViewType,
    title: String,
    displayMode: DisplayMode
  ) {
    self.init(
      leftView: leftView,
      title: title,
      rightItems: [],
      displayMode: displayMode
    )
  }
  
  public convenience init(
    leftView: LeftViewType,
    rigthItems: [PhotiNavigationButton],
    displayMode: DisplayMode
  ) {
    self.init(
      leftView: leftView,
      title: "",
      rightItems: rigthItems,
      displayMode: displayMode
    )
  }
  
  public convenience init(leftView: LeftViewType, displayMode: DisplayMode) {
    self.init(
      leftView: leftView,
      title: "",
      rightItems: [],
      displayMode: displayMode
    )
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
    setupLeftViewUI(for: leftViewType)
    configureTitle(title)
    configureRightItems(rightItems)
  }
  
  func setViewHierarchy() {
    addSubviews(leftContentView, titleLabel, rightStackView)
  }
  
  func setConstraints() {
    leftContentView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(leftViewLeadingInset)
      $0.top.bottom.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    rightStackView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-11)
    }
  }
  
  func setupLeftViewUI(for type: LeftViewType) {
    let leftInsertingView = leftView
    
    leftContentView.addSubview(leftInsertingView)
    leftInsertingView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    configureLeftView(for: type)
    leftView.sizeToFit()
  }
}

// MARK: - Private Methods
private extension PhotiNavigationBar {
  func configureLeftView(for type: LeftViewType) {
    switch type {
      case .backButton:
        backButton.configure(with: leftBackButtonImage)
      case .logo:
        logoImageView.image = leftLogoImage
      case let .title(titleString):
        leftTitleLabel.attributedText = titleString.attributedString(
          font: .heading1,
          color: labelColor
        )
    }
  }
  
  func configureRightView(for mode: DisplayMode) {
    rightItems.forEach { $0.convert(color: rightButtonImageColor) }
  }
  
  func configureTitle(_ title: String) {
    titleLabel.attributedText = title.attributedString(
      font: .body1Bold,
      color: labelColor
    )
  }
  
  func configureRightItems(_ items: [UIView]) {
    items.forEach { rightStackView.addArrangedSubview($0) }
    configureRightView(for: displayMode)
    rightStackView.sizeToFit()
  }
}
