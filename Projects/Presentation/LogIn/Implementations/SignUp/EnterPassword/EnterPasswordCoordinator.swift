//
//  EnterPasswordCoordinator.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol EnterPasswordViewModelable { }

protocol EnterPasswordListener: AnyObject {
  func didTapBackButtonAtEnterPassword()
  func didFinishEnterPassword(userId: String)
}

final class EnterPasswordCoordinator: Coordinator, EnterPasswordCoordinatable {
  weak var listener: EnterPasswordListener?
  
  private let viewController: EnterPasswordViewController
  private let viewModel: EnterPasswordViewModel
  
  init(viewModel: EnterPasswordViewModel) {
    self.viewModel = viewModel
    self.viewController = EnterPasswordViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtEnterPassword()
  }
  
  func didTapContinueButton(userId: String) {
    listener?.didFinishEnterPassword(userId: userId)
  }
}
