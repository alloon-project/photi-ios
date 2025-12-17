//
//  LogInViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import CoreUI
import DesignSystem

final class LogInViewController: UIViewController, ViewControllerable {
  private var cancellables = Set<AnyCancellable>()
  private let viewModel: LogInViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    title: "로그인",
    displayMode: .dark
  )
  
  private let idTextField = LineTextField(placeholder: "아이디를 입력해주세요.", type: .helper)
  private let passwordTextField = PasswordTextField(placeholder: "비밀번호를 입력해주세요", type: .helper)
  private let loginButton = FilledRoundButton(type: .primary, size: .xLarge, text: "로그인")
  private let findView = FindView()
  private let signUpButton = LineRoundButton(text: "회원가입", type: .primary, size: .xLarge)
  
  private let warningToastView = ToastView(
    tipPosition: .none, text: "아이디와 비밀번호 모두 입력해주세요", icon: .bulbWhite
  )
  private let invalidId = CommentView(
    .warning, text: "아이디 또는 비밀번호가 일치하지 않아요", icon: .closeRed, isActivate: true
  )
  private let invalidPassword = CommentView(
    .warning, text: "아이디 또는 비밀번호가 일치하지 않아요", icon: .closeRed, isActivate: true
  )
  
  // MARK: - Initiazliers
  init(viewModel: LogInViewModel) {
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    hideTabBar(animated: false)
  }
  
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension LogInViewController {
  func setupUI() {
    self.navigationController?.navigationBar.isHidden = true
    self.view.backgroundColor = .white

    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() { 
    view.addSubviews(navigationBar, idTextField, passwordTextField, loginButton, findView, signUpButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    idTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(idTextField.snp.bottom).offset(16)
    }
    
    loginButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(passwordTextField.snp.bottom).offset(40)
    }
    
    findView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(loginButton.snp.bottom).offset(25)
    }
    
    signUpButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
    
    warningToastView.setConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-64)
    }
  }
}

// MARK: - Bind Method
private extension LogInViewController {
  func bind() {
    let input = LogInViewModel.Input(
      id: idTextField.textPublisher,
      password: passwordTextField.textPublisher,
      didTapBackButton: navigationBar.didTapBackButton,
      didTapLoginButton: loginButton.tapPublisher,
      didTapFindIdButton: findView.findIdTapPublisher,
      didTapFindPasswordButton: findView.findPasswordTapPublisher,
      didTapSignUpButton: signUpButton.tapPublisher
    )
   
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    idTextField.textPublisher
      .sinkOnMain(with: self) { owner, _ in
        owner.idTextField.commentViews = []
        owner.idTextField.mode = .default
      }.store(in: &cancellables)
    
    passwordTextField.textPublisher
      .sinkOnMain(with: self) { owner, _ in
        owner.passwordTextField.commentViews = []
        owner.passwordTextField.mode = .default
      }.store(in: &cancellables)
    
    loginButton.tapPublisher
      .sinkOnMain(with: self) { owner, _ in
        owner.view.endEditing(true)
      }.store(in: &cancellables)
  }
  
  func bind(for output: LogInViewModel.Output) {
    output.emptyIdOrPassword
      .sinkOnMain(with: self) { owner, _ in
        owner.idTextField.commentViews = []
        owner.passwordTextField.commentViews = []
        
        owner.idTextField.mode = .default
        owner.passwordTextField.mode = .default
        owner.displayToastView()
      }.store(in: &cancellables)
   
    output.invalidIdOrPassword
      .sinkOnMain(with: self) { owner, _ in
        owner.idTextField.commentViews = [owner.invalidId]
        owner.passwordTextField.commentViews = [owner.invalidPassword]
        
        owner.idTextField.mode = .error
        owner.passwordTextField.mode = .error
      }.store(in: &cancellables)
    
    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableToastView()
      }.store(in: &cancellables)
    
    output.loadingAnimation
      .sinkOnMain(with: self) { owner, isStart in
        isStart ? owner.loginButton.startLoadingAnimation() : owner.loginButton.stopLoadingAnimation()
        owner.view.isUserInteractionEnabled = !isStart
      }.store(in: &cancellables)
    }
}

// MARK: - LogInPresentable
extension LogInViewController: LogInPresentable { }

// MARK: - Private Methods
private extension LogInViewController {
  func displayToastView() {
    warningToastView.present(to: self)
  }
}
