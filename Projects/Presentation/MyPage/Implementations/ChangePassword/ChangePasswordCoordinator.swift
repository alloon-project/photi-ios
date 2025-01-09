//
//  ChangePasswordCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol ChangePasswordListener: AnyObject {
  func didTapBackButtonAtChangePassword()
  func didChangedPassword()
}

protocol ChangePasswordPresentable { }

final class ChangePasswordCoordinator: ViewableCoordinator<ChangePasswordPresentable> {
  weak var listener: ChangePasswordListener?

  private let viewModel: ChangePasswordViewModel
  
  init(
    viewControllerable: ViewControllable,
    viewModel: ChangePasswordViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension ChangePasswordCoordinator: ChangePasswordCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtChangePassword()
  }
  
  func didChangedPassword() {
    listener?.didChangedPassword()
  }
}
