//
//  EnterPasswordViewController.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import Core
import DesignSystem

final class EnterPasswordViewController: UIViewController, ViewControllerable {
  private var cancellables = Set<AnyCancellable>()
  private let viewModel: EnterPasswordViewModel
  
  private let bottomSheetTitle = "포티 서비스 이용을 위한\n필수 약관에 동의해주세요"
  private let bottomSheetDataSource = ["서비스 이용약관 동의", "개인정보 수집 및 이용 동의"]
  
  private let didTapContinueButton = PassthroughSubject<Void, Never>()
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let progressBar = LargeProgressBar(step: .three)
  
  private let passwordTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "비밀번호를 입력해주세요".attributedString(
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
  
  // MARK: - Initializers
  init(viewModel: EnterPasswordViewModel) {
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.progressBar.step = .four
    }  }
  
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension EnterPasswordViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    passwordTextField.commentViews = [
      containAlphabetCommentView,
      containNumberCommentView,
      containSpecialCommentView,
      validRangeCommentView
    ]
    
    passwordCheckTextField.commentViews = [correnspondPasswordCommentView]
    
    setViewHierarchy()
    setConstraints()
    [passwordCheckTitleLabel, passwordCheckTextField].forEach { $0.isHidden = true }
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(
      navigationBar,
      progressBar,
      passwordTitleLabel,
      passwordTextField,
      nextButton
    )
    self.view.addSubviews(passwordCheckTitleLabel, passwordCheckTextField)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    progressBar.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    passwordTitleLabel.snp.makeConstraints {
      $0.top.equalTo(progressBar.snp.bottom).offset(48)
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
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension EnterPasswordViewController {
  func bind() {
    let input = EnterPasswordViewModel.Input(
      password: passwordTextField.textPublisher,
      reEnteredPassword: passwordCheckTextField.textPublisher,
      didTapBackButton: navigationBar.didTapBackButton,
      didTapContinueButton: didTapContinueButton.eraseToAnyPublisher()
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(output: output)
  }
  
  func viewBind() {
    nextButton.tapPublisher
      .sinkOnMain(with: self) { owner, _ in
        owner.presentBottomSheet()
      }.store(in: &cancellables)
  }
  
  func bind(output: EnterPasswordViewModel.Output) {
    output.containAlphabet
      .assign(to: \.isActivate, on: containAlphabetCommentView)
      .store(in: &cancellables)
    
    output.containNumber
      .assign(to: \.isActivate, on: containNumberCommentView)
      .store(in: &cancellables)
    
    output.containSpecial
      .assign(to: \.isActivate, on: containSpecialCommentView)
      .store(in: &cancellables)
    
    output.isValidRange
      .assign(to: \.isActivate, on: validRangeCommentView)
      .store(in: &cancellables)
    
    output.correspondPassword
      .withLatestFrom(output.isValidPassword) { $0 && $1 }
      .assign(to: \.isActivate, on: correnspondPasswordCommentView)
      .store(in: &cancellables)
    
    output.isEnabledNextButton
      .assign(to: \.isEnabled, on: nextButton)
      .store(in: &cancellables)
    
    output.isValidPassword
      .sinkOnMain(with: self) { owner, isValid in
        guard isValid, owner.passwordCheckTextField.isHidden else { return }
        owner.passwordCheckTextField.isHidden = false
        owner.passwordCheckTitleLabel.isHidden = false
      }.store(in: &cancellables)
    
    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }.store(in: &cancellables)
    
    output.registerError
      .sinkOnMain(with: self) { owner, message in
        owner.presentRegisterFailWarning(message: message)
      }.store(in: &cancellables)
  }
}

// MARK: - EnterPasswordPresentable
extension EnterPasswordViewController: EnterPasswordPresentable { }

// MARK: - Private Methods
private extension EnterPasswordViewController {
  func presentBottomSheet() {
    let alert = ListBottomSheetViewController(
      title: bottomSheetTitle,
      button: "동의 후 계속",
      dataSource: bottomSheetDataSource
    )
    alert.delegate = self
    
    alert.present(to: self, animated: true) { [weak self] in
      self?.progressBar.step = .five
    }
    
    alert.didDismiss
      .map { _ in PhotiProgressStep.four }
      .bind(to: \.step, on: progressBar)
      .store(in: &cancellables)
  }
  
  func presentRegisterFailWarning(message: String) {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "회원가입 오류가 발생했어요",
      subTitle: message
    )
    
    alert.present(to: self, animted: true)
  }
}

extension EnterPasswordViewController: ListBottomSheetDelegate {
  func didTapIcon(_ bottomSheet: ListBottomSheetViewController, at index: Int) {
    let url = index == 0 ? ServiceConfiguration.shared.termsUrl : ServiceConfiguration.shared.privacyUrl
    let webviewController = WebViewController(url: url)
    webviewController.modalPresentationStyle = .pageSheet
    
    if let sheet = webviewController.sheetPresentationController {
      sheet.prefersGrabberVisible = true
  }

    bottomSheet.present(webviewController, animated: true)
  }
  
  func didTapButton(_ bottomSheet: ListBottomSheetViewController) {
    bottomSheet.dismissBottomSheet()
    didTapContinueButton.send(())
  }
}
