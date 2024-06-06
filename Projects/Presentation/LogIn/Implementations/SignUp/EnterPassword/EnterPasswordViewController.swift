//
//  EnterPasswordViewController.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class EnterPasswordViewController: UIViewController {
  private let viewModel: EnterPasswordViewModel
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .none, iconType: .one)
  private let progressBar = LargeProgressBar(step: .four)
  
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
  
  // TODO: - DS 적용후 이미지 수정
  private let containAlphabetCommentView = CommentView(
    .condition, text: "숫자 포함", icon: UIImage(systemName: "checkmark")!
  )
  private let containNumberCommentView = CommentView(
    .condition, text: "숫자 포함", icon: UIImage(systemName: "checkmark")!
  )
  private let containSpecialCommentView = CommentView(
    .condition, text: "특수문자 포함", icon: UIImage(systemName: "checkmark")!
  )
  private let validRangeCommentView = CommentView(
    .condition, text: "8~30자", icon: UIImage(systemName: "checkmark")!
  )

  private let correnspondPasswordCommentView = CommentView(
    .condition, text: "비밀번호 일치", icon: UIImage(systemName: "checkmark")!
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
  }
  
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
      containAlphabetCommentView, containNumberCommentView, containSpecialCommentView, validRangeCommentView
    ]
    
    passwordCheckTextField.commentViews = [correnspondPasswordCommentView]
                                            
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() { 
    self.view.addSubviews(navigationBar, progressBar, passwordTitleLabel, passwordTextField, nextButton)
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
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalTo(passwordTitleLabel.snp.bottom).offset(24)
    }
    
    passwordCheckTitleLabel.snp.makeConstraints {
      $0.top.equalTo(passwordTextField.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    passwordCheckTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalTo(passwordCheckTitleLabel.snp.bottom).offset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}
