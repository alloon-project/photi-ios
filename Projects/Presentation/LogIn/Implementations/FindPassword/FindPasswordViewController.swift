//
//  FindPasswordViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Core
import DesignSystem

final class FindPasswordViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let viewModel: FindPasswordViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    title: "비밀번호 찾기",
    displayMode: .dark
  )
  
  private let enterIdLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.attributedText = "아이디를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    return label
  }()
  
  private let idTextField: LineTextField = {
    let textField = LineTextField(placeholder: "아이디", type: .default)
    textField.setKeyboardType(.default)
    return textField
  }()
  
  private let idWarningView = CommentView(
    .warning,
    text: "ID 형태가 올바르지 않아요",
    icon: UIImage(systemName: "xmark")!,
    isActivate: true
  )
  private let announceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.attributedText = "가입 시 사용했던 이메일을 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    return label
  }()
  private let emailFormWarningView = CommentView(
    .warning,
    text: "이메일 형태가 올바르지 않아요",
    icon: UIImage(systemName: "xmark")!,
    isActivate: true
  )
  private let emailTextCountWarningView = CommentView(
    .warning,
    text: "100자 이하의 이메일을 사용해주세요",
    icon: UIImage(systemName: "xmark")!,
    isActivate: true
  )
  private let emailTextField: LineTextField = {
    let textField = LineTextField(placeholder: "이메일", type: .default)
    textField.setKeyboardType(.emailAddress)
    return textField
  }()
  
  private let nextButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "다음"
  )
  
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
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      enterIdLabel,
      idTextField,
      announceLabel,
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
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
    
    idTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(enterIdLabel.snp.bottom).offset(20)
    }
    
    announceLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(idTextField.snp.bottom).offset(40)
    }
    
    emailTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(announceLabel.snp.bottom).offset(20)
    }
    
    nextButton.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension FindPasswordViewController {
  func bind() {
    let input = FindPasswordViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      userId: idTextField.rx.text,
      endEditingUserId: idTextField.textField.rx.controlEvent(.editingDidEnd),
      editingUserId: idTextField.textField.rx.controlEvent(.editingChanged),
      userEmail: emailTextField.rx.text,
      endEditingUserEmail: emailTextField.textField.rx.controlEvent(.editingDidEnd),
      editingUserEmail: emailTextField.textField.rx.controlEvent(.editingChanged),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: FindPasswordViewModel.Output) {
    output.isVaildId
      .emit(with: self) { onwer, isValid in
        if isValid {
          onwer.convertIdTextField(commentView: nil)
        } else {
          onwer.convertIdTextField(commentView: onwer.idWarningView)
        }
      }.disposed(by: disposeBag)
    
    output.isValidEmailForm
      .emit(with: self) { onwer, isValid in
        if isValid {
          onwer.convertEmailTextField(commentView: nil)
        } else {
          onwer.convertEmailTextField(commentView: onwer.emailFormWarningView)
        }
      }.disposed(by: disposeBag)
    
    output.isOverMaximumText
      .emit(with: self) { owner, isOver in
        if isOver {
          owner.convertEmailTextField(commentView: owner.emailTextCountWarningView)
        } else {
          owner.convertEmailTextField(commentView: nil)
        }
      }
      .disposed(by: disposeBag)
    
    output.isEnabledNextButton
      .emit(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.invalidIdOrEmail
      .emit(with: self) { onwer, _ in
        onwer.displayToastView()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension FindPasswordViewController {
  func convertIdTextField(commentView: CommentView?) {
    if let commentView = commentView {
      idTextField.commentViews = [commentView]
      idTextField.mode = .error
    } else {
      idTextField.commentViews = []
      idTextField.mode = .success
    }
  }
  
  func convertEmailTextField(commentView: CommentView?) {
    if let commentView = commentView {
      emailTextField.commentViews = [commentView]
      emailTextField.mode = .error
    } else {
      emailTextField.commentViews = []
      emailTextField.mode = .success
    }
  }
  
  func displayToastView() {
    warningToastView.present(to: self)
  }
}
