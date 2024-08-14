//
//  LogInViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import DesignSystem
import Core

final class LogInViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let viewModel: LogInViewModel
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .center, iconType: .one, titleText: "로그인")
  private let idTextField = LineTextField(placeholder: "아이디를 입력해주세요.", type: .helper)
  private let passwordTextField = PasswordTextField(placeholder: "비밀번호를 입력해주세요", type: .helper)
  private let loginButton = FilledRoundButton(type: .primary, size: .xLarge, text: "로그인")
  private let findView = FindView()
  private let signUpButton = LineRoundButton(text: "회원가입", type: .primary, size: .xLarge)
  
  // TODO: - DS 적용 후 수정
  private let warningToastView = ToastView(
    tipPosition: .none, text: "아이디와 비밀번호 모두 입력해주세요", icon: UIImage(systemName: "lightbulb.fill")!
  )
  private let invalidId = CommentView(
    .warning, text: "아이디 또는 비밀번호가 일치하지 않아요", icon: UIImage(systemName: "xmark")!, isActivate: true
  )
  private let invalidPassword = CommentView(
    .warning, text: "아이디 또는 비밀번호가 일치하지 않아요", icon: UIImage(systemName: "xmark")!, isActivate: true
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
    
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
      id: idTextField.rx.text,
      password: passwordTextField.rx.text,
      didTapLoginButton: loginButton.rx.tap,
      didTapFindIdButton: findView.rx.didTapFindIdButton,
      didTapFindPasswordButton: findView.rx.didTapFindPasswordButton,
      didTapSignUpButton: signUpButton.rx.tap
    )
    
    idTextField.rx.text
      .distinctUntilChanged()
      .bind(with: self) { owner, _ in
        owner.idTextField.commentViews = []
        owner.idTextField.mode = .default
      }
      .disposed(by: disposeBag)
    
    passwordTextField.rx.text
      .distinctUntilChanged()
      .bind(with: self) { owner, _ in
        owner.passwordTextField.commentViews = []
        owner.passwordTextField.mode = .default
      }
      .disposed(by: disposeBag)
    
    loginButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: disposeBag)
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: LogInViewModel.Output) {
    output.emptyIdOrPassword
      .emit(with: self) { owner, _ in
        owner.idTextField.commentViews = []
        owner.passwordTextField.commentViews = []
        
        owner.idTextField.mode = .default
        owner.passwordTextField.mode = .default
        owner.displayToastView()
      }
      .disposed(by: disposeBag)
   
    output.invalidIdOrPassword
      .emit(with: self) { owner, _ in
        owner.idTextField.commentViews = [owner.invalidId]
        owner.passwordTextField.commentViews = [owner.invalidPassword]
        
        owner.idTextField.mode = .error
        owner.passwordTextField.mode = .error
      }
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.displayAlertPopUp()
      }
      .disposed(by: disposeBag)
    }
}

// MARK: - Private Methods
private extension LogInViewController {
  func displayToastView() {
    warningToastView.present(to: self)
  }
  
  func displayAlertPopUp() {
    let alertVC = AlertViewController(alertType: .confirm, title: "오류", subTitle: "잠시 후에 다시 시도해주세요.")
    alertVC.present(to: self, animted: false)
  }
}
