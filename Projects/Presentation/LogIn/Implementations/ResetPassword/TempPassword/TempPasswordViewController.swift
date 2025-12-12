//
//  TempPasswordViewController.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import Core
import DesignSystem

final class TempPasswordViewController: UIViewController, ViewControllerable {
  private var cancellables: Set<AnyCancellable> = []
  private let viewModel: TempPasswordViewModel
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, title: "비밀번호 찾기", displayMode: .dark)
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "이메일로 임시 비밀번호를 보내드렸습니다\n임시 비밀번호를 입력해주세요".attributedString(font: .heading4, color: .gray900)
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
  private let resendButton = TextButton(
    text: "재전송",
    size: .xSmall,
    type: .primary,
    isEnabledUnderLine: true
  )
  private let tempPasswordTextField = LineTextField(placeholder: "임시 비밀번호", type: .helper)
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "다음")
  
  private let tempPasswordWarningView = CommentView(
    .warning, text: "임시 비밀번호가 일치하지 않아요", icon: .closeRed, isActivate: false
  )
  
  private let resendEmailToastView = ToastView(
    tipPosition: .none,
    text: "인증메일이 재전송되었어요",
    icon: .bulbWhite
  )
  
  private let failedresendEmailToastView = ToastView(
    tipPosition: .none,
    text: "인증메일 전송에 실패했어요. 다시 시도해주세요",
    icon: .closeRed
  )
  
  private let informationView = {
    let view = UIView()
    view.backgroundColor = .blue0
    view.layer.cornerRadius = 12
    
    return view
  }()
  private let informationTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "이메일이 오지 않는 경우".attributedString(
      font: .caption1,
      color: .gray900
    )
    
    return label
  }()
  private let informationContentLabel: UILabel = {
    let label = UILabel()
    label.attributedText = """
    · 입력하신 이메일 주소가 정확한지 확인해 주세요.
    · 스팸 메일함을 확인해 주세요.
    · 재전송 요청 버튼을 눌러 메일을 다시 받아주세요.
    """.attributedString(
      font: .caption1,
      color: .gray700
    )
    label.numberOfLines = 3
    return label
  }()
  
  // MARK: - Initalizers
  init(viewModel: TempPasswordViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
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
private extension TempPasswordViewController {
  func setupUI() {
    view.backgroundColor = .white
    tempPasswordTextField.commentViews = [tempPasswordWarningView]
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, titleLabel)
    view.addSubviews(
      emailLabel,
      userEmailLabel,
      resendButton,
      tempPasswordTextField,
      informationView,
      nextButton
    )
    informationView.addSubviews(
      informationTitleLabel,
      informationContentLabel
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(40)
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
    
    tempPasswordTextField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(userEmailLabel.snp.bottom).offset(24)
    }
    
    informationView.snp.makeConstraints {
      $0.leading.trailing.equalTo(tempPasswordTextField)
      $0.top.equalTo(tempPasswordTextField.snp.bottom).offset(16)
      $0.height.equalTo(108)
    }
    
    informationTitleLabel.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview().inset(16)
    }
    
    informationContentLabel.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(16)
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    nextButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(56)
    }
    
    [resendEmailToastView, failedresendEmailToastView].forEach {
      $0.setConstraints {
        $0.centerX.equalToSuperview()
        $0.bottom.equalToSuperview().inset(64)
      }
    }
  }
}

// MARK: - Bind Methods
extension TempPasswordViewController {
  func bind() {
    let input = TempPasswordViewModel.Input(
      password: tempPasswordTextField.textPublisher,
      didTapBackButton: navigationBar.didTapBackButton,
      didTapResendButton: resendButton.tapPublisher,
      didTapNextButton: nextButton.tapPublisher
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(output: output)
  }
  
  func viewBind() {
    tempPasswordTextField.textField.eventPublisher(for: .editingChanged)
      .sinkOnMain(with: self) { owner, _ in
        owner.tempPasswordWarningView.isActivate = false
        owner.tempPasswordTextField.mode = .default
      }.store(in: &cancellables)
  }
  
  func bind(output: TempPasswordViewModel.Output) {
    output.isEnabledNextButton
      .assign(to: \.isEnabled, on: nextButton)
      .store(in: &cancellables)
    
    output.isSuccessedResend
      .sinkOnMain(with: self) { owner, isSuccess in
        isSuccess ? owner.presentToastView() : owner.presentFailedToastView()
      }.store(in: &cancellables)
    
    output.invalidPassword
      .sinkOnMain(with: self) { owner, _ in
        owner.tempPasswordWarningView.isActivate = true
        owner.tempPasswordTextField.mode = .error
      }.store(in: &cancellables)
  }
}

// MARK: - Presenterable
extension TempPasswordViewController: TempPasswordPresentable {
  func configureUserEmail(_ email: String) {
    userEmailLabel.attributedText = email.attributedString(
      font: .caption1,
      color: .gray700
    )
  }
}

// MARK: - Private Methods
private extension TempPasswordViewController {
  func presentToastView() {
    resendEmailToastView.present(to: self)
  }
  
  func presentFailedToastView() {
    failedresendEmailToastView.present(to: self)
  }
}
