//
//  ChangePasswordCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol ChangePasswordViewModelable { }

public protocol ChangePasswordListener: AnyObject {
  func didTapBackButtonAtChangePassword()
  func didChangedPassword()
}

final class ChangePasswordCoordinator: Coordinator {
  weak var listener: ChangePasswordListener?
  
  private let viewController: ChangePasswordViewController
  private let viewModel: ChangePasswordViewModel
  
  init(viewModel: ChangePasswordViewModel) {
    self.viewModel = viewModel
    self.viewController = ChangePasswordViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
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
