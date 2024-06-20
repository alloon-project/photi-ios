//
//  TempPasswordCoordinator.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol TempPasswordViewModelable {
  // Coordinator에서 ViewModel로 전달할 이벤트입니다.
}

protocol TempPasswordListener: AnyObject {
  func didTapBackButtonAtTempPassword()
}

final class TempPasswordCoordinator: Coordinator, TempPasswordCoordinatable {
  weak var listener: TempPasswordListener?
  private let userEmail: String
  
  private let viewController: TempPasswordViewController
  private let viewModel: any TempPasswordViewModelType
  
  init(viewModel: TempPasswordViewModel, userEmail: String) {
    self.viewModel = viewModel
    self.userEmail = userEmail
    self.viewController = TempPasswordViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    viewController.setUserEmail(userEmail)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
