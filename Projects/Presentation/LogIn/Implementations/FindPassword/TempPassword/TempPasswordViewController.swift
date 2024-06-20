//
//  TempPasswordViewController.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//


import UIKit
import DesignSystem

final class TempPasswordViewController: UIViewController {
  private let viewModel: TempPasswordViewModel
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .center, iconType: .one, titleText: "비밀번호 찾기")
  private let enterTempPasswordLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.attributedText = "이메일로 임시 비밀번호를 보내드렸습니다\n임시 비밀번호를 입력해주세요".attributedString(font: .heading4, color: .gray900)
    label.numberOfLines = 2
    return label
  }()
  private let tempPasswordWarningView = CommentView(
    .warning, text: "임시 비밀번호가 일치하지 않아요", icon: UIImage(systemName: "xmark")!, isActivate: true
  )
  private let userEmailLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.attributedText = "".attributedString(font: .heading4, color: .gray700)
    return label
  }()
  private let resendButton = TextButton(text: "재전송", size: .xSmall, type: .primary, isEnabledUnderLine: true)
  private let tempPasswordTextField: LineTextField = {
    let textField = LineTextField(placeholder: "임시 비밀번호", type: .default)
    textField.setKeyboardType(.default)
    return textField
  }()
  
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  
  // MARK: - Initalizers
  init(viewModel: TempPasswordViewModel) {
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
  }
  
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension TempPasswordViewController {
  func setupUI() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, enterTempPasswordLabel, userEmailLabel, resendButton, tempPasswordTextField,
                     nextButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    enterTempPasswordLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
    
    userEmailLabel.snp.makeConstraints {
      $0.leading.equalTo(enterTempPasswordLabel)
      $0.top.equalTo(enterTempPasswordLabel.snp.bottom).offset(16)
    }
    
    resendButton.snp.makeConstraints {
      $0.leading.equalTo(userEmailLabel.snp.trailing).offset(8)
      $0.centerY.equalTo(userEmailLabel)
    }
    
    tempPasswordTextField.snp.makeConstraints {
      $0.leading.equalTo(userEmailLabel)
      $0.top.equalTo(userEmailLabel.snp.bottom).offset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Internal Methods
extension TempPasswordViewController {
  func setUserEmail(_ email: String) {
    userEmailLabel.attributedText = "이메일 : \(email)".attributedString(
      font: .caption1,
      color: .gray700
    )
  }
}
