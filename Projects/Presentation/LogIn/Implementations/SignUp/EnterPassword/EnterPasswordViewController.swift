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
  private let disposeBag = DisposeBag()
  private let viewModel: EnterPasswordViewModel
  
  private let bottomSheetTitle = "얼른 서비스 이용을 위한\n필수 약관에 동의해주세요"
  private let bottomSheetDataSource = ["서비스 이용약관 동의", "개인정보 수집 및 이용 동의"]
  
  private let didTapContinueButton = PublishRelay<Void>()
  
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
    .condition, text: "영문 포함", icon: UIImage(systemName: "checkmark")!
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
    bind()
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

// MARK: - Bind Methods
private extension EnterPasswordViewController {
  func bind() {
    let input = EnterPasswordViewModel.Input(
      password: passwordTextField.rx.text,
      reEnteredPassword: passwordCheckTextField.rx.text,
      didTapBackButton: navigationBar.rx.didTapLeftButton,
      didTapContinueButton: ControlEvent(events: didTapContinueButton.asObservable())
    )
    
    nextButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.presentBottomSheet()
      }
      .disposed(by: disposeBag)
    
    let output = viewModel.transform(input: input)
    bind(output: output)
  }
  
  func bind(output: EnterPasswordViewModel.Output) {
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
      .drive(passwordCheckTextField.rx.isHidden)
      .disposed(by: disposeBag)
    
    output.isValidPassword
      .map { !$0 }
      .drive(passwordCheckTitleLabel.rx.isHidden)
      .disposed(by: disposeBag)
    
    output.isValidPassword
      .filter { $0 == false }
      .map { _ in "" }
      .drive(with: self) { owner, _ in
        owner.passwordCheckTextField.text = ""
        owner.correnspondPasswordCommentView.isActivate = false
      }
      .disposed(by: disposeBag)
    
    output.correspondPassword
      .drive(correnspondPasswordCommentView.rx.isActivate)
      .disposed(by: disposeBag)
    
    output.isEnabledNextButton
      .drive(nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentWarningPopup()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Private Methods
private extension EnterPasswordViewController {
  func presentBottomSheet() {
    let alert = ListBottomSheetViewController(
      title: bottomSheetTitle,
      button: "동의 후 계속",
      dataSource: bottomSheetDataSource
    )
    alert.delegate = self
    
    alert.present(to: self, animated: true) { [weak self] in
      self?.progressBar.step = .five
    }
    
    alert.didDismiss
      .map { _ in PhotiProgressStep.four }
      .bind(to: progressBar.rx.step)
      .disposed(by: disposeBag)
  }
}

extension EnterPasswordViewController: ListBottomSheetDelegate {
  func didTapIcon(at index: Int) {  }
  
  func didTapButton(_ bottomSheet: ListBottomSheetViewController) {
    bottomSheet.dismissBottomSheet()
    didTapContinueButton.accept(())
  }
}
