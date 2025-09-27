//
//  NoneMemberHomeViewController.swift
//  HomeImpl
//
//  Created by jung on 9/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxSwift
import SnapKit
import DesignSystem
import Core

final class NoneMemberHomeViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private let viewModel: NoneMemberHomeViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .logo, displayMode: .dark)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "회원님을 기다리고 있는\n챌린지들이예요".attributedString(
      font: .heading1,
      color: .gray900
    )
    label.numberOfLines = 0
    
    return label
  }()
  
  private let mainImageView = UIImageView(image: .homeNoneMember)
  private let loginButton = FilledRoundButton(type: .primary, size: .xLarge, text: "회원가입하고 참여하기")
  
  // MARK: - Initializers
  init(viewModel: NoneMemberHomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
  }
}

// MARK: - UI Methods
private extension NoneMemberHomeViewController {
  func setupUI() {
    view.backgroundColor = .white
    mainImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, titleLabel, mainImageView, loginButton)
  }
  
  func setConstraints() {
    let tabBarMinY = tabBarController?.tabBar.frame.minY ?? 0
    let tabBarHeight = view.frame.height - tabBarMinY
    navigationBar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.trailing.leading.equalToSuperview()
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(24)
    }
    
    mainImageView.snp.makeConstraints {
      $0.leading.trailing.lessThanOrEqualToSuperview()
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.height.lessThanOrEqualTo(407)
    }
    
    loginButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(mainImageView.snp.bottom).offset(16)
      $0.bottom.lessThanOrEqualToSuperview().inset(tabBarHeight + 16)
    }
  }
}

// MARK: - Bind Methods
private extension NoneMemberHomeViewController {
  func bind() {
    let input = NoneMemberHomeViewModel.Input(didTapLogInButton: loginButton.rx.tap)
    
    viewModel.transform(input: input)
  }
}

// MARK: - NoneMemberHomePresentable
extension NoneMemberHomeViewController: NoneMemberHomePresentable { }
