//
//  ChangePasswordViewController.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Coordinator
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChangePasswordViewController: UIViewController, ViewControllerable {
  var keyboardShowNotification: NSObjectProtocol?
  var keyboardHideNotification: NSObjectProtocol?
  
  private let viewModel: ChangePasswordViewModel
  private let disposeBag = DisposeBag()
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
  
  private let newPasswordTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "새 비밀번호를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  private let newPasswordCheckTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "새 비밀번호를 한 번 더 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()

  private let currentPasswordTextField = PasswordTextField(placeholder: "기존 비밀번호", type: .helper)
  private let newPasswordTextField = PasswordTextField(placeholder: "새 비밀번호", type: .helper)
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
  
  private let invalidCurrentPasswordCommentView = CommentView(
    .warning,
    text: "기존 비밀번호가 일치하지 않아요",
    icon: .closeRed,
    isActivate: true
  )
  
  private let duplicatePasswordCommentView = CommentView(
    .warning,
    text: "새 비밀번호는 기존 비밀번호와 동일할 수 없어요",
    icon: .closeRed,
    isActivate: true
  )
  
  private let containAlphabetCommentView = CommentView(
    .condition, text: "영문 포함", icon: .checkGray400
  )
  private let containNumberCommentView = CommentView(
    .condition, text: "숫자 포함", icon: .checkGray400
  )
  private let containSpecialCommentView = CommentView(
    .condition, text: "특수문자 포함", icon: .checkGray400
  )
  private let validRangeCommentView = CommentView(
    .condition, text: "8~30자", icon: .checkGray400
  )
  
  private let correnspondNewPasswordCommentView = CommentView(
    .condition, text: "새 비밀번호 일치", icon: .checkGray400
  )
  
  private lazy var newPassWordCommentViews = [
    containAlphabetCommentView,
    containNumberCommentView,
    containSpecialCommentView,
    validRangeCommentView
  ]
  
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
    
    setupUI()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    keyboardShowNotification = registerKeyboardShowNotification()
    keyboardHideNotification = registerKeyboardHideNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    removeKeyboardNotification(keyboardShowNotification, keyboardHideNotification)
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
    view.backgroundColor = .white
    newPasswordTextField.commentViews = newPassWordCommentViews
    newPasswordCheckTextField.commentViews = [correnspondNewPasswordCommentView]
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(
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
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(currentPasswordTitleLabel.snp.bottom).offset(24)
    }
    
    newPasswordTitleLabel.snp.makeConstraints {
      $0.top.equalTo(currentPasswordTextField.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    newPasswordTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(newPasswordTitleLabel.snp.bottom).offset(24)
    }
    
    newPasswordCheckTitleLabel.snp.makeConstraints {
      $0.top.equalTo(newPasswordTextField.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    newPasswordCheckTextField.snp.makeConstraints {
      $0.top.equalTo(newPasswordCheckTitleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    changePasswordButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(56)
    }
    
    forgotPasswordButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(changePasswordButton.snp.top).offset(-14)
    }
  }
}

// MARK: - Bind
private extension ChangePasswordViewController {
  func bind() {
    let backButtonEvent: ControlEvent<Void> = {
      let events = Observable<Void>.create { [weak navigationBar] observer in
        guard let bar = navigationBar else { return Disposables.create() }
        let cancellable = bar.didTapBackButton
          .sink { observer.onNext(()) }
        return Disposables.create { cancellable.cancel() }
      }
      return ControlEvent(events: events)
    }()
    
    let input = ChangePasswordViewModel.Input(
      currentPassword: currentPasswordTextField.textField.rx.text.orEmpty,
      newPassword: newPasswordTextField.textField.rx.text.orEmpty,
      reEnteredPassword: newPasswordCheckTextField.textField.rx.text.orEmpty,
      didTapBackButton: backButtonEvent,
      didTapForgetPasswordButton: forgotPasswordButton.rx.tap,
      didTapChangePasswordButton: changePasswordButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(output: output)
  }
  
  func viewBind() {
    currentPasswordTextField.textField.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(with: self) { owner, _ in
        guard !owner.currentPasswordTextField.commentViews.isEmpty else { return }
        owner.currentPasswordTextField.mode = .default
        owner.currentPasswordTextField.commentViews = []
      }
      .disposed(by: disposeBag)
    
    newPasswordTextField.textField.rx.text.orEmpty
      .distinctUntilChanged()
      .bind(with: self) { owner, _ in
        guard owner.newPasswordTextField.commentViews != owner.newPassWordCommentViews else { return }
        owner.newPasswordTextField.mode = .default
        owner.newPasswordTextField.commentViews = owner.newPassWordCommentViews
      }
      .disposed(by: disposeBag)
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
    
    output.isValidNewPassword
      .map { !$0 }
      .drive(newPasswordCheckTextField.rx.isHidden)
      .disposed(by: disposeBag)
    
    output.isValidNewPassword
      .map { !$0 }
      .drive(newPasswordCheckTitleLabel.rx.isHidden)
      .disposed(by: disposeBag)
    
    output.isValidNewPassword
      .filter { $0 == false }
      .drive(with: self) { owner, _ in
        owner.newPasswordCheckTextField.text = ""
        owner.correnspondNewPasswordCommentView.isActivate = false
      }
      .disposed(by: disposeBag)
    
    output.correspondNewPassword
      .drive(correnspondNewPasswordCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isEnabledNextButton
      .drive(changePasswordButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.invalidCurrentPassword
      .emit(with: self) { owner, _ in
        owner.currentPasswordTextField.mode = .error
        owner.currentPasswordTextField.commentViews = [owner.invalidCurrentPasswordCommentView]
      }
      .disposed(by: disposeBag)
    
    output.duplicatePassword
      .emit(with: self) { owner, _ in
        owner.newPasswordTextField.mode = .error
        owner.newPasswordTextField.commentViews = [owner.duplicatePasswordCommentView]
      }
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ChangePasswordPresentable
extension ChangePasswordViewController: ChangePasswordPresentable { }

// MARK: - KeyboardListener
extension ChangePasswordViewController: KeyboardListener {
  func keyboardWillShow(keyboardHeight: CGFloat) {
    guard let activeTextField = [currentPasswordTextField, newPasswordTextField, newPasswordCheckTextField]
      .first(where: { $0.textField.isFirstResponder }) else { return }
    
    let textFieldBottomY = activeTextField.convert(activeTextField.bounds, to: self.view).maxY
    let keyboardOriginY = self.view.frame.height - keyboardHeight
    let offset = textFieldBottomY - keyboardOriginY
    
    guard offset > 0 else { return }
    
    UIView.animate(withDuration: 0.25) {
      self.view.frame.origin.y = -offset - 16
    }
  }
  
  func keyboardWillHide() {
    UIView.animate(withDuration: 0.25) {
      self.view.frame.origin.y = 0
    }
  }
} 

// MARK: - Private Methods
private extension ChangePasswordViewController { }
