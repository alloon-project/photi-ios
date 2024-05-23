//
//  VerifyEmailCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol VerifyEmailViewModelable { }

protocol VerifyEmailListener: AnyObject { }

final class VerifyEmailCoordinator: Coordinator, VerifyEmailCoordinatable {
  weak var listener: VerifyEmailListener?
  private let userEmail: String
  
  private let viewController: VerifyEmailViewController
  private let viewModel: VerifyEmailViewModel
  
  init(viewModel: VerifyEmailViewModel, userEmail: String) {
    self.viewModel = viewModel
    self.userEmail = userEmail
    self.viewController = VerifyEmailViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    viewController.setUserEmail(userEmail)
    navigationController?.pushViewController(viewController, animated: false)
  }
}
