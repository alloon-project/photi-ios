//
//  NewPasswordCoordinator.swift
//  LogInImpl
//
//  Created by wooseob on 6/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol NewPasswordViewModelable { }

protocol NewPasswordListener: AnyObject {
  func didTapBackButtonAtNewPassword()
  func didFinishFindPassword()
}

final class NewPasswordCoordinator: Coordinator, NewPasswordCoordinatable {
  weak var listener: NewPasswordListener?
  
  private let viewController: NewPasswordViewController
  private let viewModel: any NewPasswordViewModelType
  
  init(viewModel: NewPasswordViewModel) {
    self.viewModel = viewModel
    self.viewController = NewPasswordViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtNewPassword()
  }
  
  func didTapResetPasswordAlert() {
    listener?.didFinishFindPassword()
  }
}
