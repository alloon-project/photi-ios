//
//  ChangePasswordViewController.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChangePasswordViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let viewModel: ChangePasswordViewModel
  private let alertRelay = PublishRelay<Void>()
  private let didTapContinueButton = PublishRelay<Void>()
  private var isKeyboardDisplay: Bool = false
  private var keyboardOffSet: CGFloat?
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let currentPasswordTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "기존 비밀번호를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    return label
  }()
  
  private let currentPasswordTextField = PasswordTextField(placeholder: "기존 비밀번호", type: .helper)
  
  private let newPasswordTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "새 비밀번호를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let newPasswordTextField = PasswordTextField(placeholder: "새 비밀번호", type: .helper)
  
  private let newPasswordCheckTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "새 비밀번호를 한 번 더 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let newPasswordCheckTextField = PasswordTextField(placeholder: "새 비밀번호 재입력", type: .helper)
  
  private let forgotPasswordButton = TextButton(
    text: "비밀번호가 기억나지 않아요",
    size: .xSmall,
    type: .primary,
    mode: .default,
    isEnabledUnderLine: true
  )
  
  private let changePasswordButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "변경하기"
  )
  
  // TODO: - DS 적용후 이미지 수정
  private let wrongPasswordCommentView = CommentView(
    .warning,
    text: "기존 비밀번호가  일치하지 않아요",
    icon: .closeRed
  )
  
  private let isDifferentPasswordCommentView = CommentView(
    .warning,
    text: "새 비밀번호는 기존 비밀번호와 동일할 수 없어요",
    icon: .closeRed
  )
  
  private let containAlphabetCommentView = CommentView(
    .condition, 
    text: "영문 포함",
    icon: .checkGray400
  )
  
  private let containNumberCommentView = CommentView(
    .condition,
    text: "숫자 포함",
    icon: .checkGray400
  )
  
  private let containSpecialCommentView = CommentView(
    .condition, 
    text: "특수문자 포함",
    icon: .checkGray400
  )
  
  private let validRangeCommentView = CommentView(
    .condition, 
    text: "8~30자",
    icon: .checkGray400
  )
  
  private let correnspondPasswordCommentView = CommentView(
    .condition, 
    text: "새 비밀번호 일치",
    icon: .checkGray400
  )
  
  private let warningToastView = ToastView(
    tipPosition: .none, text: "권한이 없는 요청입니다. 로그인 후에 다시 시도 해주세요.", icon: .bulbWhite
  )
  
  // MARK: - Initializers
  init(viewModel: ChangePasswordViewModel) {
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
    
    wrongPasswordCommentView.isActivate = true
    isDifferentPasswordCommentView.isActivate = true
    
    currentPasswordTextField.textField.delegate = self
    newPasswordTextField.textField.delegate = self
    newPasswordCheckTextField.textField.delegate = self
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardAppear),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    )
    setupUI()
    bind()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    )
  }
  // MARK: - UIResponder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ChangePasswordViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    newPasswordTextField.commentViews = [
      containAlphabetCommentView,
      containNumberCommentView,
      containSpecialCommentView,
      validRangeCommentView
    ]
    newPasswordCheckTextField.commentViews = [correnspondPasswordCommentView]
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.view.addSubviews(
      navigationBar,
      currentPasswordTitleLabel,
      currentPasswordTextField,
      newPasswordTitleLabel,
      newPasswordTextField,
      newPasswordCheckTitleLabel,
      newPasswordCheckTextField,
      forgotPasswordButton,
      changePasswordButton
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    currentPasswordTitleLabel.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(24)
      $0.leading.equalToSuperview().offset(24)
    }
    
    currentPasswordTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(currentPasswordTitleLabel.snp.bottom).offset(24)
    }
    
    newPasswordTitleLabel.snp.makeConstraints {
      $0.top.equalTo(currentPasswordTextField.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    newPasswordTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(newPasswordTitleLabel.snp.bottom).offset(24)
    }
    
    newPasswordCheckTitleLabel.snp.makeConstraints {
      $0.top.equalTo(newPasswordTextField.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    newPasswordCheckTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(newPasswordCheckTitleLabel.snp.bottom).offset(24)
    }
    
    changePasswordButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
    
    forgotPasswordButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(changePasswordButton.snp.top).offset(-14)
    }
    
    warningToastView.setConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-64)
    }
  }
}

// MARK: - Bind
private extension ChangePasswordViewController {
  func bind() {
    let input = ChangePasswordViewModel.Input(
      currentPassword: currentPasswordTextField.rx.text,
      newPassword: newPasswordTextField.rx.text,
      reEnteredPassword: newPasswordCheckTextField.rx.text,
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapChangePasswordButton: changePasswordButton.rx.tap,
      didAppearAlert: alertRelay
    )
    
    let output = viewModel.transform(input: input)
    bind(output: output)
  }
  
  func bind(output: ChangePasswordViewModel.Output) {
    output.containAlphabet
      .drive(containAlphabetCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.containNumber
      .drive(containNumberCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.containSpecial
      .drive(containSpecialCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isValidRange
      .drive(validRangeCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isValidPassword
      .map { !$0 }
      .drive(newPasswordCheckTextField.rx.isHidden)
      .disposed(by: disposeBag)
    
    output.isValidPassword
      .map { !$0 }
      .drive(newPasswordCheckTitleLabel.rx.isHidden)
      .disposed(by: disposeBag)
    
    output.isValidPassword
      .filter { $0 == false }
      .map { _ in "" }
      .drive(with: self) { owner, _ in
        owner.newPasswordCheckTextField.text = ""
        owner.correnspondPasswordCommentView.isActivate = false
      }
      .disposed(by: disposeBag)
    
    output.correspondPassword
      .drive(correnspondPasswordCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isEnabledNextButton
      .drive(changePasswordButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.tokenUnauthorized
      .emit(with: self) { onwer, _ in
        onwer.displayToastView()
      }.disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { onwer, _ in
        onwer.displayAlertPopUp()
      }.disposed(by: disposeBag)
    
    output.unMatchedCurrentPassword
      .emit(with: self) { onwer, _ in
        onwer.currentPasswordTextField.commentViews = [onwer.wrongPasswordCommentView]
      }.disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension ChangePasswordViewController {
  @objc func keyboardAppear(notification: Notification) {
    guard let userInfo = notification.userInfo,
          let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
      return
    }
    let textFieldBottom =  newPasswordCheckTextField.frame.maxY
    keyboardOffSet = textFieldBottom - keyboardFrame.minY
  }
  
  func displayToastView() {
    warningToastView.present(to: self)
  }
  
  func displayAlertPopUp() {
    let alertVC = AlertViewController(alertType: .confirm, title: "오류", subTitle: "잠시 후에 다시 시도해주세요.")
    alertVC.present(to: self, animted: false)
  }
}

// MARK: - UITextFieldDelegate
extension ChangePasswordViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == currentPasswordTextField && currentPasswordTextField.commentViews == [wrongPasswordCommentView] {
      currentPasswordTextField.text = nil
      currentPasswordTextField.commentViews.removeAll()
    }
    
    if textField == newPasswordTextField && newPasswordTextField.commentViews == [isDifferentPasswordCommentView] {
      newPasswordTextField.text = nil
      newPasswordTextField.commentViews = [
        containAlphabetCommentView,
        containNumberCommentView,
        containSpecialCommentView,
        validRangeCommentView
      ]
    }
    
    if let keyboardOffSet, keyboardOffSet > 0 {
      UIView.animate(withDuration: 0.2) {
        self.view.frame.origin.y -= keyboardOffSet
      }
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == currentPasswordTextField.textField || textField == newPasswordTextField.textField {
      let isDifferentPassword = currentPasswordTextField.text != newPasswordTextField.text
      if !isDifferentPassword && newPasswordTextField.text != nil {
        newPasswordTextField.commentViews = [isDifferentPasswordCommentView]
      } else {
        newPasswordTextField.commentViews = [
          containAlphabetCommentView,
          containNumberCommentView,
          containSpecialCommentView,
          validRangeCommentView
        ]
      }
    }
    if let keyboardOffSet, keyboardOffSet > 0 {
      UIView.animate(withDuration: 0.2) {
        self.view.frame.origin.y += keyboardOffSet
      }
    }
  }
}
