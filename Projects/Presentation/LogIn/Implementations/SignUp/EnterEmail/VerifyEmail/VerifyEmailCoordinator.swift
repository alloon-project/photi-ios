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
  
  private let viewController: VerifyEmailViewController
  private let viewModel: any VerifyEmailViewModelType
  
  override init() {
    self.viewController = VerifyEmailViewController()
    self.viewModel = VerifyEmailViewModel()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}
