//
//  FindPasswordViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import Core
import DesignSystem

final class FindPasswordViewController: UIViewController, ViewControllerable {
  private var cancellables: Set<AnyCancellable> = []
  private let viewModel: FindPasswordViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, title: "비밀번호 찾기", displayMode: .dark )
  private let enterIdLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "아이디를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    return label
  }()
  
  private let enterEmailLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "가입 시 사용했던 이메일을 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    return label
  }()
  
  private let idTextField = LineTextField(placeholder: "아이디", type: .default)
  private let emailTextField: LineTextField = {
    let textField = LineTextField(placeholder: "이메일", type: .default)
    textField.setKeyboardType(.emailAddress)
    return textField
  }()
  
  private let idWarningView = CommentView(
    .warning,
    text: "아이디 형태가 올바르지 않아요",
    icon: .closeRed,
    isActivate: true
  )

  private let emailFormWarningView = CommentView(
    .warning,
    text: "이메일 형태가 올바르지 않아요",
    icon: .closeRed,
    isActivate: true
  )

  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  
  private let warningToastView = ToastView(
    tipPosition: .none,
    text: "아이디 혹은 이메일이 일치하지 않아요",
    icon: .bulbWhite
  )
  
  // MARK: - Initializers
  init(viewModel: FindPasswordViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Life Cycle
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
private extension FindPasswordViewController {
  func setupUI() {
    view.backgroundColor = .white
    nextButton.isEnabled = false
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      enterIdLabel,
      idTextField,
      enterEmailLabel,
      emailTextField,
      nextButton
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    enterIdLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
    
    idTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(enterIdLabel.snp.bottom).offset(20)
    }
    
    enterEmailLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(idTextField.snp.bottom).offset(40)
    }
    
    emailTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(enterEmailLabel.snp.bottom).offset(20)
    }
    
    nextButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(56)
    }
    
    warningToastView.setConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(64)
    }
  }
}

// MARK: - Bind Methods
private extension FindPasswordViewController {
  func bind() {
    let input = FindPasswordViewModel.Input(
      didTapBackButton: navigationBar.didTapBackButton,
      userId: idTextField.textPublisher,
      endEditingUserId: idTextField.textField.eventPublisher(for: .editingDidEnd),
      userEmail: emailTextField.textPublisher,
      endEditingUserEmail: emailTextField.textField.eventPublisher(for: .editingDidEnd),
      didTapNextButton: nextButton.tap()
    )
    
    let output = viewModel.transform(input: input)
    
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    idTextField.textField.eventPublisher(for: .editingChanged)
      .sinkOnMain(with: self) { owner, _ in
        owner.convertIdTextField(commentView: nil)
      }.store(in: &cancellables)
    
    emailTextField.textField.eventPublisher(for: .editingChanged)
      .sinkOnMain(with: self) { owner, _ in
        owner.convertEmailTextField(commentView: nil)
      }.store(in: &cancellables)
  }
  
  func bind(for output: FindPasswordViewModel.Output) {
    output.inValidIdFormat
      .sinkOnMain(with: self) { owner, _ in
        owner.convertIdTextField(commentView: owner.idWarningView)
      }.store(in: &cancellables)

    output.inValidEmailFormat
      .sinkOnMain(with: self) { owner, _ in
        owner.convertEmailTextField(commentView: owner.emailFormWarningView)
      }.store(in: &cancellables)

    output.isEnabledNextButton
      .bind(to: \.isEnabled, on: nextButton)
      .store(in: &cancellables)
    
    output.unMatchedIdOrEmail
      .sinkOnMain(with: self) { onwer, _ in
        onwer.displayToastView()
      }.store(in: &cancellables)
    
    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }.store(in: &cancellables)
  }
}

// MARK: - FindPasswordPresentable
extension FindPasswordViewController: FindPasswordPresentable { }

// MARK: - Private Methods
private extension FindPasswordViewController {
  func convertIdTextField(commentView: CommentView?) {
    if let commentView = commentView {
      idTextField.commentViews = [commentView]
      idTextField.mode = .error
    } else {
      idTextField.commentViews = []
      idTextField.mode = .default
    }
  }
  
  func convertEmailTextField(commentView: CommentView?) {
    if let commentView = commentView {
      emailTextField.commentViews = [commentView]
      emailTextField.mode = .error
    } else {
      emailTextField.commentViews = []
      emailTextField.mode = .default
    }
  }
  
  func displayToastView() {
    warningToastView.present(to: self)
  }
}
