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
import RxSwift
import RxRelay
import SnapKit
import Core
import DesignSystem

final class FindIdViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private var cancellables: Set<AnyCancellable> = []
  private let alertRelay = PublishRelay<Void>()
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
      didTapBackButton: navigationBar.rx.didTapBackButton.asSignal(),
      email: emailTextField.textField.rx.text.orEmpty.asDriver(onErrorJustReturn: ""),
      endEditingUserEmail: emailTextField.textField.rx.controlEvent(.editingDidEnd).asSignal(),
      didTapNextButton: nextButton.rx.tap.asSignal(),
      didAppearAlert: alertRelay.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(for: output)
  }
  
  func viewBind() {
    alertVC.didTapConfirmButton
      .sinkOnMain(with: self) { owner, _ in
        owner.alertRelay.accept(())
      }.store(in: &cancellables)
    
    emailTextField.textField.rx.controlEvent(.editingChanged)
      .bind(with: self) { owner, _ in
        owner.emailTextField.mode = .default
        owner.emailTextField.commentViews.forEach { $0.isActivate = false }
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for output: FindIdViewModel.Output) {
    output.invalidFormat
      .emit(with: self) { owner, _ in
        owner.emailTextField.mode = .error
        owner.emailTextField.commentViews = [owner.invalidEmail]
        owner.invalidEmail.isActivate = true
      }
      .disposed(by: disposeBag)

    output.notRegisteredEmail
      .emit(with: self) { owner, _ in
        owner.emailTextField.mode = .error
        owner.emailTextField.commentViews = [owner.isWrongEmail]
        owner.isWrongEmail.isActivate = true
      }
      .disposed(by: disposeBag)
    
    output.successEmailVerification
      .emit(with: self) { owner, _ in
        owner.alertVC.present(to: owner, animted: false)
      }
      .disposed(by: disposeBag)
    
    output.isEnabledConfirm
      .drive(nextButton.rx.isEnabled)
      .disposed(by: disposeBag)

    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - FindIdPresentable
extension FindIdViewController: FindIdPresentable { }
