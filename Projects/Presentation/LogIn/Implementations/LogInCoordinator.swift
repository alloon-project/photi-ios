//
//  LogInCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import LogIn

protocol LogInViewModelable { }

final class LogInCoordinator: Coordinator, LogInCoordinatable {
  weak var listener: LogInListener?
  
  private let viewController: LogInViewController
  private let viewModel: any LogInViewModelType
  
  override init() {
    self.viewController = LogInViewController()
    self.viewModel = LogInViewModel()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}
