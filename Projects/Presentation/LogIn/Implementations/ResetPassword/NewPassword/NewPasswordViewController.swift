//
//  NewPasswordViewController.swift
//  LogInImpl
//
//  Created by wooseob on 6/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import CoreUI
import DesignSystem

final class NewPasswordViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private var cancellables: Set<AnyCancellable> = []
  private let viewModel: NewPasswordViewModel
  private let didTapConfirmButtonAtAlert = PublishRelay<Void>()
  
  private let didTapBackButtonRelay = PublishRelay<Void>()
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, title: "비밀번호 재설정", displayMode: .dark)
  
  private let passwordTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "새 비밀번호를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    return label
  }()
  
  private let passwordTextField = PasswordTextField(placeholder: "비밀번호", type: .helper)
  
  private let passwordCheckTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "한 번 더 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    return label
  }()
  
  private let passwordCheckTextField = PasswordTextField(placeholder: "비밀번호 확인", type: .helper)
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  
  private let containAlphabetCommentView = CommentView(
    .condition, text: "영문 포함", icon: .checkGray400
  )
  private let containNumberCommentView = CommentView(
    .condition, text: "숫자 포함", icon: .checkGray400
  )
  private let containSpecialCommentView = CommentView(
    .condition, text: "특수문자 포함", icon: .checkGray400
  )
  private let validRangeCommentView = CommentView(
    .condition, text: "8~30자", icon: .checkGray400
  )
  
  private let correnspondPasswordCommentView = CommentView(
    .condition, text: "비밀번호 일치", icon: .checkGray400
  )
  
  private let alertView = AlertViewController(
    alertType: .confirm,
    title: "비밀번호가 변경되었어요",
    subTitle: "새 비밀번호로 로그인 해주세요"
  )
  
  // MARK: - Initializers
  init(viewModel: NewPasswordViewModel) {
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
  
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension NewPasswordViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    passwordTextField.commentViews = [
      containAlphabetCommentView, containNumberCommentView, containSpecialCommentView, validRangeCommentView
    ]
    passwordCheckTextField.commentViews = [correnspondPasswordCommentView]
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, passwordTitleLabel, passwordTextField, nextButton)
    view.addSubviews(passwordCheckTitleLabel, passwordCheckTextField)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    passwordTitleLabel.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(passwordTitleLabel.snp.bottom).offset(24)
    }
    
    passwordCheckTitleLabel.snp.makeConstraints {
      $0.top.equalTo(passwordTextField.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    passwordCheckTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(passwordCheckTitleLabel.snp.bottom).offset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(56)
    }
  }
}

// MARK: - Bind Methods
private extension NewPasswordViewController {
  func bind() {
    let input = NewPasswordViewModel.Input(
      password: passwordTextField.textField.rx.text.orEmpty,
      reEnteredPassword: passwordCheckTextField.textField.rx.text.orEmpty,
      didTapBackButton: didTapBackButtonRelay.asSignal(),
      didTapContinueButton: nextButton.rx.tap.asSignal(),
      didTapConfirmButtonAtAlert: didTapConfirmButtonAtAlert.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(output: output)
  }
  
  func viewBind() {
    alertView.didTapConfirmButton
      .sinkOnMain(with: self) { owner, _ in
        owner.didTapConfirmButtonAtAlert.accept(())
      }.store(in: &cancellables)
    
    navigationBar.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.didTapBackButtonRelay.accept(())
      }.store(in: &cancellables)
  }
  
  func bind(output: NewPasswordViewModel.Output) {
    output.containAlphabet
      .drive(containAlphabetCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.containNumber
      .drive(containNumberCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.containSpecial
      .drive(containSpecialCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isValidRange
      .drive(validRangeCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isValidPassword
      .map { !$0 }
      .drive(passwordCheckTextField.rx.isHidden)
      .disposed(by: disposeBag)

    output.isValidPassword
      .map { !$0 }
      .drive(passwordCheckTitleLabel.rx.isHidden)
      .disposed(by: disposeBag)
    
    output.isValidPassword
      .filter { $0 == false }
      .map { _ in "" }
      .drive(with: self) { owner, _ in
        owner.passwordCheckTextField.text = ""
        owner.correnspondPasswordCommentView.isActivate = false
      }
      .disposed(by: disposeBag)
    
    output.correspondPassword
      .drive(correnspondPasswordCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isEnabledNextButton
      .drive(nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.isStartedUpdatePassword
      .emit(with: self) { owner, isStart in
        isStart ? owner.nextButton.startLoadingAnimation() : owner.nextButton.stopLoadingAnimation()
        owner.view.isUserInteractionEnabled = !isStart
      }
      .disposed(by: disposeBag)
    
    output.isSuccessedUpdatePassword
      .emit(with: self) { owner, isSuccessed in
        if isSuccessed {
          owner.presentConfirmAlertView()
        } else {
          owner.presentNetworkUnstableAlert()
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - NewPasswordPresentable
extension NewPasswordViewController: NewPasswordPresentable { }

// MARK: - Private Methods
private extension NewPasswordViewController {
  func presentConfirmAlertView() {
    guard !alertView.isPresenting else { return }
    
    alertView.present(to: self, animted: true)
  }
}
