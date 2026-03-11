//
//  AgreementViewController.swift
//  LogInImpl
//
//  Created by Codex on 3/2/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import Core
import CoreUI
import DesignSystem

final class AgreementViewController: UIViewController, ViewControllerable {
  private var cancellables = Set<AnyCancellable>()
  private let viewModel: AgreementViewModel
  
  private let bottomSheetTitle = "포티 서비스 이용을 위한\n필수 약관에 동의해주세요"
  private let bottomSheetDataSource = ["서비스 이용약관 동의", "개인정보 수집 및 이용 동의"]
  
  private let didTapContinueButton = PassthroughSubject<Void, Never>()
  
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  private let progressBar = LargeProgressBar(step: .four)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.attributedText = "거의 다 완료됐어요.\n약관 동의를 진행해주세요".attributedString(
      font: .heading4,
      color: .gray900
    )
    return label
  }()
  
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.attributedText = "필수 약관 동의 후 회원가입이 완료됩니다.".attributedString(
      font: .caption1,
      color: .gray700
    )
    return label
  }()
  
  private let nextButton = FilledRoundButton(type: .primary, size: .xLarge, text: "약관 동의")
  
  init(viewModel: AgreementViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.progressBar.step = .five
    }
  }
}

private extension AgreementViewController {
  func setupUI() {
    view.backgroundColor = .white
    view.addSubviews(navigationBar, progressBar, titleLabel, subtitleLabel, nextButton)
    
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
    
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(24)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
  
  func bind() {
    let input = AgreementViewModel.Input(
      didTapBackButton: navigationBar.didTapBackButton,
      didTapContinueButton: didTapContinueButton.eraseToAnyPublisher()
    )
    
    let output = viewModel.transform(input: input)
    viewBind()
    bind(output: output)
  }
  
  func viewBind() {
    nextButton.tapPublisher
      .sinkOnMain(with: self) { owner, _ in
        owner.presentBottomSheet()
      }.store(in: &cancellables)
  }
  
  func bind(output: AgreementViewModel.Output) {
    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }.store(in: &cancellables)
    
    output.registerError
      .sinkOnMain(with: self) { owner, message in
        owner.presentRegisterFailWarning(message: message)
      }.store(in: &cancellables)
  }
  
  func presentBottomSheet() {
    let alert = ListBottomSheetViewController(
      title: bottomSheetTitle,
      button: "동의 후 계속",
      dataSource: bottomSheetDataSource
    )
    alert.delegate = self
    
    alert.present(to: self, animated: true)
    
    alert.didDismiss
      .map { _ in PhotiProgressStep.five }
      .bind(to: \.step, on: progressBar)
      .store(in: &cancellables)
  }
  
  func presentRegisterFailWarning(message: String) {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "회원가입 오류가 발생했어요",
      subTitle: message
    )
    
    alert.present(to: self, animted: true)
  }
}

extension AgreementViewController: AgreementPresentable { }

extension AgreementViewController: ListBottomSheetDelegate {
  func didTapIcon(_ bottomSheet: ListBottomSheetViewController, at index: Int) {
    let url = index == 0 ? ServiceConfiguration.shared.termsUrl : ServiceConfiguration.shared.privacyUrl
    let webviewController = WebViewController(url: url)
    webviewController.modalPresentationStyle = .pageSheet
    
    if let sheet = webviewController.sheetPresentationController {
      sheet.prefersGrabberVisible = true
    }
    
    bottomSheet.present(webviewController, animated: true)
  }
  
  func didTapButton(_ bottomSheet: ListBottomSheetViewController) {
    bottomSheet.dismissBottomSheet()
    didTapContinueButton.send(())
  }
}
