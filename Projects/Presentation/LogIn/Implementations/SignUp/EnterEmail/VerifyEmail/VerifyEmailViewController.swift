//
//  VerifyEmailViewController.swift
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

final class VerifyEmailViewController: UIViewController, ViewControllerable {
  private let disposeBag = DisposeBag()
  private let viewModel: VerifyEmailViewModel
  
  private let didTapEmailNotFoundConfirmButton = PublishRelay<Void>()
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let progressBar = LargeProgressBar(step: .two)
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "이메일로 인증코드를 보내드렸습니다\n숫자 4자리를 입력해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    label.numberOfLines = 2
    
    return label
  }()
  private let emailLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "이메일:".attributedString(
      font: .caption1,
      color: .gray700
    )
    
    return label
  }()
  private let userEmailLabel = UILabel()
  private let resendButton = TextButton(text: "재전송", size: .xSmall, type: .primary)
  
  private let lineTextField = LineTextField(placeholder: "숫자 4자리", type: .helper)
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  
  private let veriftCodeErrorCommentView = CommentView(
    .warning, text: "인증코드가 일치하지 않아요", icon: .closeRed
  )
  
  // MARK: - Initalizers
  init(viewModel: VerifyEmailViewModel) {
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
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension VerifyEmailViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    resendButton.isEnabledUnderLine = true
    lineTextField.setKeyboardType(.numberPad)
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, progressBar, titleLabel, emailLabel, userEmailLabel, resendButton)
    view.addSubviews(lineTextField, nextButton)
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
    
    emailLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.centerY.equalTo(resendButton)
    }
    
    userEmailLabel.snp.makeConstraints {
      $0.leading.equalTo(emailLabel.snp.trailing).offset(4)
      $0.centerY.equalTo(resendButton)
    }
    
    resendButton.snp.makeConstraints {
      $0.leading.equalTo(userEmailLabel.snp.trailing).offset(8)
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
    }
    
    lineTextField.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(resendButton.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension VerifyEmailViewController {
  func bind() {
    let input = VerifyEmailViewModel.Input(
      didTapBackButton: navigationBar.rx.didTapBackButton,
      didTapResendButton: resendButton.rx.tap,
      didTapNextButton: nextButton.rx.tap,
      verificationCode: lineTextField.rx.text
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: VerifyEmailViewModel.Output) {
    output.isEnabledNextButton
      .emit(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentWarningPopup()
      }
      .disposed(by: disposeBag)
    
    output.emailNotFound
      .emit(with: self) { owner, _ in
        owner.displayEmailNotFoundPopUp()
      }
      .disposed(by: disposeBag)
    
    output.invalidVerificationCode
      .emit(with: self) { owner, _ in
        owner.lineTextField.commentViews = [owner.veriftCodeErrorCommentView]
        owner.veriftCodeErrorCommentView.isActivate = true
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - VerifyEmailPresentable
extension VerifyEmailViewController: VerifyEmailPresentable {
  func setUserEmail(_ email: String) {
    userEmailLabel.attributedText = email.attributedString(
      font: .caption1,
      color: .gray700
    )
  }
}

// MARK: - Private Methods
private extension VerifyEmailViewController {
  func displayEmailNotFoundPopUp() {
    let alertVC = AlertViewController(alertType: .confirm, title: "오류", subTitle: "해당 이메일이 존재하지 않습니다.")
    alertVC.present(to: self, animted: false)
  }
}
