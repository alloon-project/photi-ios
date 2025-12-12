//
//  VerifyEmailViewController.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import Core
import DesignSystem

final class VerifyEmailViewController: UIViewController, ViewControllerable {
  private var cancellables = Set<AnyCancellable>()
  private let viewModel: VerifyEmailViewModel
    
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let progressBar = LargeProgressBar(step: .one)
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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.progressBar.step = .two
    }
  }
  
  // MARK: - UI Responder
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
    view.addSubviews(
      navigationBar,
      progressBar,
      titleLabel,
      emailLabel,
      userEmailLabel,
      resendButton
    )
    view.addSubviews(
      lineTextField,
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
    
    informationView.snp.makeConstraints {
      $0.leading.trailing.equalTo(lineTextField)
      $0.top.equalTo(lineTextField.snp.bottom).offset(32)
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
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension VerifyEmailViewController {
  func bind() {
    let input = VerifyEmailViewModel.Input(
      didTapBackButton: navigationBar.didTapBackButton,
      didTapResendButton: resendButton.tapPublisher,
      didTapNextButton: nextButton.tapPublisher,
      verificationCode: lineTextField.textPublisher
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
    viewBind()
  }
  
  func viewBind() {
    resendButton.tapPublisher
      .sinkOnMain(with: self) { owner, _ in
        owner.presentResendToast()
      }.store(in: &cancellables)
  }
  
  func bind(for output: VerifyEmailViewModel.Output) {
    output.isEnabledNextButton
      .assign(to: \.isEnabled, on: nextButton)
      .store(in: &cancellables)
    
    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }.store(in: &cancellables)
        
    output.invalidVerificationCode
      .sinkOnMain(with: self) { owner, _ in
        owner.lineTextField.commentViews = [owner.veriftCodeErrorCommentView]
        owner.lineTextField.mode = .error
        owner.veriftCodeErrorCommentView.isActivate = true
      }.store(in: &cancellables)
  }
}

// MARK: - VerifyEmailPresentable
extension VerifyEmailViewController: VerifyEmailPresentable {
  func configureUserEmail(_ email: String) {
    userEmailLabel.attributedText = email.attributedString(
      font: .caption1,
      color: .gray700
    )
  }
}

// MARK: - Private Methods
private extension VerifyEmailViewController {
  func presentResendToast() {
    let toast = ToastView(tipPosition: .none, text: "인증메일이 재전송되었어요", icon: .bulbWhite)
    
    toast.setConstraints {
      $0.bottom.equalToSuperview().offset(-64)
      $0.centerX.equalToSuperview()
    }
    
    toast.present(to: self)
  }
}
