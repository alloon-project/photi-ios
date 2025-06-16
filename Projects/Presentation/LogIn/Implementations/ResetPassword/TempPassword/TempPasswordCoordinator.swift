//
//  TempPasswordCoordinator.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol TempPasswordListener: AnyObject {
  func didTapBackButtonAtTempPassword()
  func didFinishTempPassword()
}

protocol TempPasswordPresentable {
  func configureUserEmail(_ email: String)
}

final class TempPasswordCoordinator: ViewableCoordinator<TempPasswordPresentable>, TempPasswordCoordinatable {
  weak var listener: TempPasswordListener?
  
  private let viewModel: TempPasswordViewModel
  private let userEmail: String
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: TempPasswordViewModel,
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

// MARK: - TempPasswordCoordinatable
extension TempPasswordCoordinator {
  func didTapBackButton() {
    listener?.didTapBackButtonAtTempPassword()
  }
  
  func attachNewPassword() {
    listener?.didFinishTempPassword()
  }
}
