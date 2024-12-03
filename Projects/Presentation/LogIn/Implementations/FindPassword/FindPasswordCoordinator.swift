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
  func didFinishFindPassword()
}

final class FindPasswordCoordinator: Coordinator, FindPasswordCoordinatable {
  weak var listener: FindPasswordListener?
  
  private let viewController: FindPasswordViewController
  private let viewModel: any FindPasswordViewModelType
  
  // MARK: - Temp Password
  private let tempPasswordContainable: TempPasswordContainable
  private var tempPasswordCoordinator: Coordinating?
  
  // MARK: - New Password
  private let newPasswordContainable: NewPasswordContainable
  private var newPasswordCoordinator: Coordinating?
  
  init(
    viewModel: FindPasswordViewModel,
    tempPasswordContainable: TempPasswordContainable,
    newPasswordContainable: NewPasswordContainable
  ) {
    self.viewModel = viewModel
    self.tempPasswordContainable = tempPasswordContainable
    self.newPasswordContainable = newPasswordContainable
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
    detachNewPassword(animated: false)
    detachTempPassword(animated: false)
  }
  
  // MARK: - Temp Password
  func attachTempPassword(userEmail: String, userName: String) {
    guard tempPasswordCoordinator == nil else { return }
    
    let coordinater = tempPasswordContainable.coordinator(
      listener: self,
      userEmail: userEmail,
      userName: userName
    )
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
  
  // MARK: - New Password
  func attatchNewPassword() {
    guard newPasswordCoordinator == nil else { return }
    
    let coordinater = newPasswordContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.newPasswordCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachNewPassword(animated: Bool) {
    guard let coordinater = newPasswordCoordinator else { return }
    
    self.newPasswordCoordinator = nil
    navigationController?.popViewController(animated: animated)
    removeChild(coordinater)
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtFindPassword()
  }
}

extension FindPasswordCoordinator: TempPasswordListener {
  func didFinishTempPassword() {
    attatchNewPassword()
  }
  
  func didTapBackButtonAtTempPassword() {
    detachTempPassword(animated: true)
  }
}

extension FindPasswordCoordinator: NewPasswordListener {
  func didTapBackButtonAtNewPassword() {
    detachNewPassword(animated: true)
  }
  
  func didFinishFindPassword() {
    listener?.didFinishFindPassword()
  }
}
