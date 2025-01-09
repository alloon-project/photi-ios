//
//  NewPasswordCoordinator.swift
//  LogInImpl
//
//  Created by wooseob on 6/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol NewPasswordListener: AnyObject {
  func didTapBackButtonAtNewPassword()
  func didFinishFindPassword()
}

protocol NewPasswordPresentable { }

final class NewPasswordCoordinator: ViewableCoordinator<NewPasswordPresentable>, NewPasswordCoordinatable {
  weak var listener: NewPasswordListener?

  private let viewModel: any NewPasswordViewModelType
  
  init(
    viewControllerable: ViewControllable,
    viewModel: NewPasswordViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtNewPassword()
  }
  
  func didTapResetPasswordAlert() {
    listener?.didFinishFindPassword()
  }
}
