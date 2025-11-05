//
//  WithdrawAuthViewController.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import RxRelay
import SnapKit
import Core
import DesignSystem

final class WithdrawAuthViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: WithdrawAuthViewModel

  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "기존 비밀번호를 입력해주세요".attributedString(font: .heading4, color: .gray900)
    return label
  }()
  
  private let passwordTextField = PasswordTextField(type: .default)
  private let withdrawButton = FilledRoundButton(type: .primary, size: .xLarge, text: "탈퇴하기", mode: .disabled)
  private let didFailPasswordVerificationAlert = AlertViewController(
    alertType: .confirm,
    title: "비밀번호가 일치하지 않아요",
    subTitle: "다시 입력해주세요"
  )
  
  // MARK: - Initiazliers
  init(viewModel: WithdrawAuthViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
  }
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension WithdrawAuthViewController {
  func setupUI() {
    view.backgroundColor = .white
//    withdrawButton.isEnabled = false
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, titleLabel, passwordTextField, withdrawButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(titleLabel.snp.bottom).offset(20)
    }
    
    withdrawButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(56)
    }
  }
}

// MARK: - Bind Method
private extension WithdrawAuthViewController {
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
    
    let input = WithdrawAuthViewModel.Input(
      didTapBackButton: backButtonEvent,
      password: passwordTextField.textField.rx.text.orEmpty,
      didTapWithdrawButton: withdrawButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    passwordTextField.textField.rx.text.orEmpty
      .map { !$0.isEmpty }
      .bind(with: self) { owner, isEntered in
        owner.withdrawButton.isEnabled = isEntered
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for output: WithdrawAuthViewModel.Output) {
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
    
    output.didFailPasswordVerification
      .emit(with: self) { owner, _ in
        owner.didFailPasswordVerificationAlert.present(to: owner, animted: true)
      }
      .disposed(by: disposeBag)
    
    output.isEnabledWithdrawButton
      .drive(withdrawButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
}

// MARK: - WithdrawAuthPresentable
extension WithdrawAuthViewController: WithdrawAuthPresentable { }
