//
//  FindPasswordCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import LogIn

protocol FindPasswordViewModelable { }

// 부모 Coordinator에게 알리고 싶을 때 사용합니다.
protocol FindPasswordListener: AnyObject {
  func didTapBackButtonAtFindPassword()
}

final class FindPasswordCoordinator: Coordinator, FindPasswordCoordinatable {
  weak var listener: FindPasswordListener?
  
  private let viewController: FindPasswordViewController
  private let viewModel: any FindPasswordViewModelType
  
  private let tempPasswordContainable: TempPasswordContainable
  private var tempPasswordCoordinator: Coordinating?
  
  init(
    viewModel: FindPasswordViewModel,
    tempPasswordContainable: TempPasswordContainable
  ) {
    self.viewModel = viewModel
    self.tempPasswordContainable = tempPasswordContainable
    self.viewController = FindPasswordViewController(viewModel: viewModel)
    
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  override func stop() {
    super.stop()
    detachTempPassword(animated: true)
  }
  
  // MARK: - TempPassword
  func attachTempPassword(userEmail: String) {
    guard tempPasswordCoordinator == nil else { return }
    
    let coordinater = tempPasswordContainable.coordinator(listener: self, userEmail: userEmail)
    addChild(coordinater)
    
    self.tempPasswordCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachTempPassword(animated: Bool) {
    guard let coordinater = tempPasswordCoordinator else { return }
    
    self.tempPasswordCoordinator = nil
    navigationController?.popViewController(animated: animated)
    removeChild(coordinater)
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtFindPassword()
  }
}

extension FindPasswordCoordinator: TempPasswordListener {
  func didTapBackButtonAtTempPassword() {
    detachTempPassword(animated: true)
  }
}
