//
//  PasswordChangeCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol PasswordChangeViewModelable { }

public protocol PasswordChangeListener: AnyObject { }

final class PasswordChangeCoordinator: Coordinator, PasswordChangeCoordinatable {
  func didTapBackButton() {
    
  }
  
  func didTapResetPasswordAlert() {
    
  }
  
  weak var listener: PasswordChangeListener?
  
  private let viewController: PasswordChangeViewController
  private let viewModel: PasswordChangeViewModel
  
  init(viewModel: PasswordChangeViewModel) {
    self.viewModel = viewModel
    self.viewController = PasswordChangeViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
