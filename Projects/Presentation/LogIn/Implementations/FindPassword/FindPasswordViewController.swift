//
//  FindPasswordViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Coordinator
import RxSwift
import RxCocoa
import SnapKit
import Core
import DesignSystem

final class FindPasswordViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
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
      didTapBackButton: navigationBar.rx.didTapBackButton.asSignal(),
      userId: idTextField.rx.text.asDriver(),
      endEditingUserId: idTextField.textField.rx.controlEvent(.editingDidEnd).asSignal(),
      userEmail: emailTextField.rx.text.asDriver(),
      endEditingUserEmail: emailTextField.textField.rx.controlEvent(.editingDidEnd).asSignal(),
      didTapNextButton: nextButton.rx.tap.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    idTextField.textField.rx.controlEvent(.editingChanged)
      .bind(with: self) { owner, _ in
        owner.convertIdTextField(commentView: nil)
      }
      .disposed(by: disposeBag)
    
    emailTextField.textField.rx.controlEvent(.editingChanged)
      .bind(with: self) { owner, _ in
        owner.convertEmailTextField(commentView: nil)
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for output: FindPasswordViewModel.Output) {
    output.inValidIdFormat
      .emit(with: self) { owner, _ in
        owner.convertIdTextField(commentView: owner.idWarningView)
      }
      .disposed(by: disposeBag)

    output.inValidEmailFormat
      .emit(with: self) { owner, _ in
        owner.convertEmailTextField(commentView: owner.emailFormWarningView)
      }
      .disposed(by: disposeBag)

    output.isEnabledNextButton
      .emit(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.unMatchedIdOrEmail
      .emit(with: self) { onwer, _ in
        onwer.displayToastView()
      }
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
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
