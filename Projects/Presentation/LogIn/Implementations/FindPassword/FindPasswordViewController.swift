//
//  FindPasswordViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import DesignSystem

final class FindPasswordViewController: UIViewController {
  private lazy var input = FindPasswordViewModel.Input(
    userId: idTextField.rx.text,
    email: emailTextField.rx.text,
    didTapNextButton: nextButton.rx.tap
  )
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .center, iconType: .one, titleText: "비밀번호 찾기")
  private let enterIdLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.attributedText = "아이디를 입력해주세요".attributedString(font: .heading4, color: .gray900)
    return label
  }()
  private let idTextField: LineTextField = {
    let textField = LineTextField(placeholder: "아이디", type: .default)
    textField.setKeyboardType(.default)
    return textField
  }()
  
  private let announceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.attributedText = "가입 시 사용했던 이메일을 입력해주세요".attributedString(font: .heading4, color: .gray900)
    return label
  }()
  private let emailTextField: LineTextField = {
    let textField = LineTextField(placeholder: "이메일", type: .default)
    textField.setKeyboardType(.emailAddress)
    return textField
  }()
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  
  // MARK: - View Life Cycle
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
private extension FindPasswordViewController {
  func setupUI() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, enterIdLabel, idTextField, announceLabel, emailTextField, nextButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    enterIdLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
    
    idTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(enterIdLabel .snp.bottom).offset(20)
    }
    
    announceLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(idTextField.snp.bottom).offset(40)
    }
    
    emailTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(announceLabel.snp.bottom).offset(20)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}
