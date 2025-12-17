//
//  FindIdViewController.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import CoreUI
import DesignSystem

final class FindIdViewController: UIViewController, ViewControllerable {
  private var cancellables: Set<AnyCancellable> = []
  private let alertSubject = PassthroughSubject<Void, Never>()
  private let viewModel: FindIdViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, title: "아이디 찾기", displayMode: .dark)
  
  private let announceLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
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
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
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
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
    }
    
    emailTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(announceLabel.snp.bottom).offset(20)
    }
    
    nextButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(56)
    }
  }
}

// MARK: - Bind Method
private extension FindIdViewController {
  func bind() {
    let input = FindIdViewModel.Input(
      didTapBackButton: navigationBar.didTapBackButton,
      email: emailTextField.textPublisher,
      endEditingUserEmail: emailTextField.textField.eventPublisher(for: .editingDidEnd),
      didTapNextButton: nextButton.tap(),
      didAppearAlert: alertSubject.eraseToAnyPublisher()
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    alertVC.didTapConfirmButton
      .sinkOnMain(with: self) { owner, _ in
        owner.alertSubject.send(())
      }.store(in: &cancellables)
    
    emailTextField.textField.eventPublisher(for: .editingChanged)
      .sinkOnMain(with: self) { owner, _ in
        owner.emailTextField.mode = .default
        owner.emailTextField.commentViews.forEach { $0.isActivate = false }
      }.store(in: &cancellables)
  }
  
  func bind(for output: FindIdViewModel.Output) {
    output.invalidFormat
      .sinkOnMain(with: self) { owner, _ in
        owner.emailTextField.mode = .error
        owner.emailTextField.commentViews = [owner.invalidEmail]
        owner.invalidEmail.isActivate = true
      }.store(in: &cancellables)

    output.notRegisteredEmail
      .sinkOnMain(with: self) { owner, _ in
        owner.emailTextField.mode = .error
        owner.emailTextField.commentViews = [owner.isWrongEmail]
        owner.isWrongEmail.isActivate = true
      }.store(in: &cancellables)
    
    output.successEmailVerification
      .sinkOnMain(with: self) { owner, _ in
        owner.alertVC.present(to: owner, animted: false)
      }.store(in: &cancellables)
    
    output.isEnabledConfirm
      .bind(to: \.isEnabled, on: nextButton)
      .store(in: &cancellables)

    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }.store(in: &cancellables)
  }
}

// MARK: - FindIdPresentable
extension FindIdViewController: FindIdPresentable { }
