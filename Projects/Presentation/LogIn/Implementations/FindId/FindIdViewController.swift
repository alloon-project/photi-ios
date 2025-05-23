//
//  FindIdViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import SnapKit
import Core
import DesignSystem

final class FindIdViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let alertRelay = PublishRelay<Void>()
  private let viewModel: FindIdViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(
    leftView: .backButton,
    title: "아이디 찾기",
    displayMode: .dark
  )
  
  private let announceLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.textAlignment = .left
    label.attributedText = "가입 시 사용했던 \n이메일을 입력해주세요".attributedString(font: .heading4, color: .gray900)
    return label
  }()
  
  private let emailTextField: LineTextField = {
    let textField = LineTextField(placeholder: "이메일", type: .helper)
    textField.setKeyboardType(.emailAddress)
    return textField
  }()
  
  private let invalidEmail = CommentView(
    .warning, text: "이메일 형태가 올바르지 않아요", icon: .closeRed
  )
  private let isWrongEmail = CommentView(
    .warning, text: "가입되지 않은 이메일이에요", icon: .closeRed
  )
  
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음", mode: .disabled) 
  
  private let alertVC = AlertViewController(
    alertType: .confirm,
    title: "이메일로 회원정보를 보내드렸어요",
    subTitle: "다시 로그인해주세요"
  )
  
  // MARK: - Initiazliers
  init(viewModel: FindIdViewModel) {
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
private extension FindIdViewController {
  func setupUI() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    self.nextButton.isEnabled = false
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, announceLabel, emailTextField, nextButton)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    announceLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
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

// MARK: - Bind Method
private extension FindIdViewController {
  func bind() {
    let input = FindIdViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      email: emailTextField.rx.text,
      endEditingUserEmail: emailTextField.textField.rx.controlEvent(.editingDidEnd),
      editingUserEmail: emailTextField.textField.rx.controlEvent(.editingChanged),
      didTapNextButton: nextButton.rx.tap,
      didAppearAlert: alertRelay
    )
    
    let output = viewModel.transform(input: input)
    
    output.isValidateEmail
      .emit(with: self) { owner, isValidate in
        if !isValidate {
          owner.emailTextField.mode = .error
          owner.emailTextField.commentViews = [owner.invalidEmail]
          owner.emailTextField.commentViews.forEach { $0.isActivate = true }
          owner.nextButton.isEnabled = false
        } else {
          owner.emailTextField.mode = .default
          owner.emailTextField.commentViews.forEach { $0.isActivate = false }
          owner.nextButton.isEnabled = true
        }
      }.disposed(by: disposeBag)
    
    output.wrongEmail
      .emit(with: self) { owner, _ in
        owner.emailTextField.mode = .error
        owner.emailTextField.commentViews = [owner.isWrongEmail]
        owner.emailTextField.commentViews.forEach { $0.isActivate = true }
        owner.nextButton.isEnabled = false
      }.disposed(by: disposeBag)
    
    output.checkEmailSucceed
      .emit(with: self) { owner, _ in
        owner.alertVC.present(to: owner, animted: false)
      }.disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
    
    alertVC.rx.isDismissing
      .bind(with: self) { owner, _ in
        owner.alertRelay.accept(())
      }.disposed(by: disposeBag)
  }
}

// MARK: - FindIdPresentable
extension FindIdViewController: FindIdPresentable { }
