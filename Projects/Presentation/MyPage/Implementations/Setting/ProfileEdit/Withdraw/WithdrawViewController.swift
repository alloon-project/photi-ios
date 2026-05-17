//
//  WithdrawViewController.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Combine
import Coordinator
import SnapKit
import CoreUI
import DesignSystem

final class WithdrawViewController: UIViewController, ViewControllerable {
  private let viewModel: WithdrawViewModel

  private var cancellables = Set<AnyCancellable>()
  private let didConfirmOAuthWithdrawSubject = PassthroughSubject<Void, Never>()

  // MARK: - UIComponents
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)

  private let titleLabel = {
    let label = UILabel()
    label.attributedText = "탈퇴 후 계정 복구는 불가해요 \n정말 탈퇴하시겠어요?".attributedString(font: .heading2, color: .gray900)
    label.numberOfLines = 2
    label.textAlignment = .center

    return label
  }()
  private let withdrawButton = LineRoundButton(text: "탈퇴 계속하기", type: .primary, size: .xLarge)
  private let cancelButton = LineRoundButton(text: "취소하기", type: .quaternary, size: .xLarge)

  private let loadingIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.hidesWhenStopped = true
    return indicator
  }()

  // MARK: - Initializers
  init(viewModel: WithdrawViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    bind()
  }
}

// MARK: - UI Methods
private extension WithdrawViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }

  func setViewHierarchy() {
    self.view.addSubviews(
      navigationBar,
      titleLabel,
      withdrawButton,
      cancelButton,
      loadingIndicator
    )
  }

  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(44)
      $0.height.equalTo(56)
    }

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(54)
      $0.centerX.equalToSuperview()
    }

    cancelButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(56)
    }

    withdrawButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalTo(cancelButton.snp.top).offset(-16)
    }

    loadingIndicator.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}

// MARK: - Bind Methods
private extension WithdrawViewController {
  func bind() {
    let input = WithdrawViewModel.Input(
      didTapBackButton: navigationBar.didTapBackButton,
      didTapWithdrawButton: withdrawButton.tapPublisher,
      didTapCancelButton: cancelButton.tapPublisher,
      didConfirmOAuthWithdraw: didConfirmOAuthWithdrawSubject.eraseToAnyPublisher()
    )

    let output = viewModel.transform(input: input)
    bind(for: output)
  }

  func bind(for output: WithdrawViewModel.Output) {
    output.showOAuthAlert
      .receive(on: DispatchQueue.main)
      .sink { [weak self] providerName in
        self?.showOAuthWithdrawAlert(providerName: providerName)
      }
      .store(in: &cancellables)

    output.isLoading
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isLoading in
        guard let self else { return }
        if isLoading {
          loadingIndicator.startAnimating()
          withdrawButton.isEnabled = false
          cancelButton.isEnabled = false
        } else {
          loadingIndicator.stopAnimating()
          withdrawButton.isEnabled = true
          cancelButton.isEnabled = true
        }
      }
      .store(in: &cancellables)

    output.networkUnstable
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.presentNetworkUnstableAlert()
      }
      .store(in: &cancellables)
  }

  func showOAuthWithdrawAlert(providerName: String) {
    let alert = AlertViewController(
      alertType: .canCancel,
      title: "\(providerName) 계정 연결을 해제하고\n탈퇴하시겠습니까?",
      subTitle: "탈퇴 시 모든 데이터가 삭제됩니다.",
      shouldDismissOnConfirm: false
    )
    alert.setConfirmButtonText("탈퇴하기")

    alert.didTapConfirmButton
      .sink { [weak self, weak alert] in
        alert?.dismiss(animated: true)
        self?.didConfirmOAuthWithdrawSubject.send(())
      }
      .store(in: &cancellables)

    alert.present(to: self, animted: true)
  }
}

// MARK: - ResignPresentable
extension WithdrawViewController: WithdrawPresentable { }
