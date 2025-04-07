//
//  VerifyEmailCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol VerifyEmailListener: AnyObject {
  func didTapBackButtonAtVerifyEmail()
  func didFinishVerifyEmail(with verificationCode: String)
}

protocol VerifyEmailPresentable {
  func configureUserEmail(_ userEmail: String)
}

final class VerifyEmailCoordinator: ViewableCoordinator<VerifyEmailPresentable> {
  weak var listener: VerifyEmailListener?
  private let userEmail: String
  
  private let viewModel: VerifyEmailViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: VerifyEmailViewModel,
    userEmail: String
  ) {
    self.viewModel = viewModel
    self.userEmail = userEmail
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    presenter.configureUserEmail(userEmail)
  }
}

extension VerifyEmailCoordinator: VerifyEmailCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtVerifyEmail()
  }
  
  func didTapNextButton(verificationCode: String) {
    listener?.didFinishVerifyEmail(with: verificationCode)
  }
}
