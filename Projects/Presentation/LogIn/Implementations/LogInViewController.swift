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
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .center, iconType: .one, titleText: "로그인")
  private let idTextField = LineTextField(placeholder: "아이디를 입력해주세요.", type: .helper)
  private let passwordTextField = PasswordTextField(placeholder: "비밀번호를 입력해주세요", type: .helper)
  private let loginButton = FilledRoundButton(type: .primary, size: .xLarge, text: "로그인")
  private let findView = FindView()
  private let signUpButton = LineRoundButton(text: "회원가입", type: .primary, size: .xLarge)
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
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
  }
}
