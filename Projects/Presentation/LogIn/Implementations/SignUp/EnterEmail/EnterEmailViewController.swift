//
//  EnterEmailViewController.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class EnterEmailViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: EnterEmailViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let progressBar = LargeProgressBar(step: .zero)
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "환영합니다!\n이메일을 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    label.numberOfLines = 2
    
    return label
  }()
  
  private let emailTextField: LineTextField = {
    let textField = LineTextField(placeholder: "이메일", type: .helper)
    textField.setKeyboardType(.emailAddress)
    return textField
  }()
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")

  private let emailFormWarningView = CommentView(
    .warning, text: "이메일 형태가 올바르지 않아요", icon: .closeRed, isActivate: true
  )
  private let emailTextCountWarningView = CommentView(
    .warning, text: "100자 이하의 이메일을 사용해주세요", icon: .closeRed, isActivate: true
  )
  private let duplicateEmailWarningView = CommentView(
    .warning, text: "이미 가입된 이메일이예요", icon: .closeRed, isActivate: true
  )
  private let emailNotExistWarningView = CommentView(
    .warning, text: "존재하지 않는 이메일이에요. 다시 확인해주세요.", icon: .closeRed, isActivate: true
  )
  
  // MARK: - Initialziers
  init(viewModel: EnterEmailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cylces
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    progressBar.step = .one
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension EnterEmailViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, progressBar, titleLabel, emailTextField, nextButton)
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
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(progressBar.snp.bottom).offset(48)
      $0.leading.equalToSuperview().offset(24)
    }
    
    emailTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension EnterEmailViewController {
  func bind() {
    let input = EnterEmailViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapNextButton: nextButton.rx.tap,
      userEmail: emailTextField.rx.text,
      endEditingUserEmail: emailTextField.textField.rx.controlEvent(.editingDidEnd),
      editingUserEmail: emailTextField.textField.rx.controlEvent(.editingChanged)
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: EnterEmailViewModel.Output) {
    output.isValidEmailForm
      .emit(with: self) { owner, isValid in
        if isValid {
          owner.convertLineTextField(commentView: nil)
        } else {
          owner.convertLineTextField(commentView: owner.emailFormWarningView)
        }
      }
      .disposed(by: disposeBag)
    
    output.isOverMaximumText
      .emit(with: self) { owner, isOver in
        if isOver {
          owner.convertLineTextField(commentView: owner.emailTextCountWarningView)
        } else {
          owner.convertLineTextField(commentView: nil)
        }
      }
      .disposed(by: disposeBag)
    
    output.isEnabledNextButton
      .emit(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .disposed(by: disposeBag)
    
    output.rejoinAvaildableDay
      .emit(with: self) { owner, day in
        owner.presentRejoinWarningAlert(dayCount: day)
      }
      .disposed(by: disposeBag)
    
    output.duplicateEmail
      .emit(with: self) { owner, _ in
        owner.convertLineTextField(commentView: owner.duplicateEmailWarningView)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - EnterEmailPresentable
extension EnterEmailViewController: EnterEmailPresentable { }

// MARK: - Private Methods
private extension EnterEmailViewController {
  func convertLineTextField(commentView: CommentView?) {
    if let commentView = commentView {
      emailTextField.commentViews = [commentView]
      emailTextField.mode = .error
    } else {
      emailTextField.commentViews = []
      emailTextField.mode = .success
    }
  }
  
  func presentRejoinWarningAlert(dayCount: Int) {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "탈퇴 처리된 계정이에요",
      subTitle: "탈퇴한 이메일 계정으로는\n\(dayCount)일 뒤 재가입 가능해요."
    )
    
    alert.present(to: self, animted: true)
  }
}
