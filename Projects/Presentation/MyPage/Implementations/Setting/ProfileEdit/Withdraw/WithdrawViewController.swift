//
//  WithdrawViewController.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxSwift
import RxCocoa
import SnapKit
import Core
import DesignSystem

final class WithdrawViewController: UIViewController, ViewControllerable {
  private let viewModel: WithdrawViewModel
  
  private let disposeBag = DisposeBag()
  // MARK: - UIComponents
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let titleLabel = {
    let label = UILabel()
    label.attributedText = "탈퇴 후 계정 복구는 불가해요 \n정말 탈퇴하시겠어요?".attributedString(font: .heading2, color: .gray900)
    label.numberOfLines = 2
    label.textAlignment = .center
    
    return label
  }()
  private let withdrawButton = LineRoundButton(text: "탈퇴 계속하기", type: .primary, size: .xLarge)
  private let cancelButton = LineRoundButton(text: "취소하기", type: .quaternary, size: .xLarge)
  
  // MARK: - Initializers
  init(viewModel: WithdrawViewModel) {
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
private extension WithdrawViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(
      navigationBar,
      titleLabel,
      withdrawButton,
      cancelButton
    )
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
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(56)
    }
    
    withdrawButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalTo(cancelButton.snp.top).offset(-16)
    }
  }
}

// MARK: - Bind Methods
private extension WithdrawViewController {
  func bind() {
    let backButtonEvent: ControlEvent<Void> = {
      let events = Observable<Void>.create { [weak navigationBar] observer in
        guard let bar = navigationBar else { return Disposables.create() }
        let cancellable = bar.didTapBackButton
          .sink { observer.onNext(()) }
        return Disposables.create { cancellable.cancel() }
      }
      return ControlEvent(events: events)
    }()
    
    let input = WithdrawViewModel.Input(
      didTapBackButton: backButtonEvent,
      didTapWithdrawButton: withdrawButton.rx.tap,
      didTapCancelButton: cancelButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: WithdrawViewModel.Output) { }
}

// MARK: - ResignPresentable
extension WithdrawViewController: WithdrawPresentable { }
