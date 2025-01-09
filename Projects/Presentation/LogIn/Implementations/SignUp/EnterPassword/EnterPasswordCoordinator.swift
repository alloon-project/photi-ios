//
//  EnterPasswordCoordinator.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol EnterPasswordListener: AnyObject {
  func didTapBackButtonAtEnterPassword()
  func didFinishEnterPassword(userName: String)
}

protocol EnterPasswordPresentable { }

final class EnterPasswordCoordinator: ViewableCoordinator<EnterPasswordPresentable> {
  weak var listener: EnterPasswordListener?
  
  private let viewModel: EnterPasswordViewModel
  
  init(
    viewControllerable: ViewControllable,
    viewModel: EnterPasswordViewModel
  ) {
    self.viewModel = viewModel
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: EnterPasswordCoordinatable
extension EnterPasswordCoordinator: EnterPasswordCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEnterPassword()
  }
  
  func didTapContinueButton(userName: String) {
    listener?.didFinishEnterPassword(userName: userName)
  }
}
