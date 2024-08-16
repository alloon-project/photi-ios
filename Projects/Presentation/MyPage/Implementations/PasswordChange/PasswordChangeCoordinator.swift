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
  weak var listener: PasswordChangeListener?
  
  private let viewController: PasswordChangeViewController
  private let viewModel: PasswordChangeViewModel
  
  init(viewModel: PasswordChangeViewModel) {
    self.viewModel = viewModel
    self.viewController = PasswordChangeViewController()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
