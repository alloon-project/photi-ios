//
//  ResignViewController.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Core
import DesignSystem

final class ResignViewController: UIViewController {
  private let viewModel: ResignViewModel
  
  private let disposeBag = DisposeBag()
  // MARK: - UIComponents
  private let navigationBar = NoneNavigationBar(rightButtonCount: .zero, mode: .dark)
  
  private let titleLabel = {
    let label = UILabel()
    label.attributedText = "탈퇴 후 계정 복구는 불가해요 \n정말 탈퇴하시겠어요?".attributedString(font: .heading2, color: .gray900)
    label.numberOfLines = 2
    label.textAlignment = .center
    
    return label
  }()
  private let resignButton = LineRoundButton(
    text: "탈퇴하기",
    type: .primary,
    size: .xLarge
  )
  
  private let cancelButton = LineRoundButton(
    text: "취소하기",
    type: .quaternary,
    size: .xLarge
  )
  
  // MARK: - Initializers
  init(viewModel: ResignViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
  }
}

// MARK: - UI Methods
private extension ResignViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(navigationBar,
                          titleLabel,
                          resignButton,
                          cancelButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(44)
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(54)
      $0.centerX.equalToSuperview()
    }
    
    cancelButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
    
    resignButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(cancelButton.snp.top).offset(-16)
    }
  }
}

// MARK: - Bind
private extension ResignViewController {
  func bind() {
    let input = ResignViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapResginButton: resignButton.rx.tap,
      didTapCancelButton: cancelButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
  }
}
