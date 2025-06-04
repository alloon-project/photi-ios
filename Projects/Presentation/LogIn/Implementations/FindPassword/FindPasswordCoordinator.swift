//
//  FindPasswordCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn

protocol FindPasswordListener: AnyObject {
  func didTapBackButtonAtFindPassword()
  func didFinishUpdatePassword()
}

protocol FindPasswordPresentable { }

final class FindPasswordCoordinator: ViewableCoordinator<FindPasswordPresentable>, FindPasswordCoordinatable {
  weak var listener: FindPasswordListener?

  private let viewModel: any FindPasswordViewModelType
  
  // MARK: - Temp Password
  private let tempPasswordContainable: TempPasswordContainable
  private var tempPasswordCoordinator: ViewableCoordinating?
  
  // MARK: - New Password
  private let newPasswordContainable: NewPasswordContainable
  private var newPasswordCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FindPasswordViewModel,
    tempPasswordContainable: TempPasswordContainable,
    newPasswordContainable: NewPasswordContainable
  ) {
    self.viewModel = viewModel
    self.tempPasswordContainable = tempPasswordContainable
    self.newPasswordContainable = newPasswordContainable
    
    super.init(viewControllerable)
    viewModel.coordinator = self
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
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.tempPasswordCoordinator = coordinater
  }
  
  func detachTempPassword() {
    guard let coordinater = tempPasswordCoordinator else { return }
    
    self.tempPasswordCoordinator = nil
    viewControllerable.popViewController(animated: true)
    removeChild(coordinater)
  }
  
  // MARK: - New Password
  func attatchNewPassword() {
    guard newPasswordCoordinator == nil else { return }
    
    let coordinater = newPasswordContainable.coordinator(listener: self)
    addChild(coordinater)
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.newPasswordCoordinator = coordinater
  }
  
  func detachNewPassword() {
    guard let coordinater = newPasswordCoordinator else { return }
    
    self.newPasswordCoordinator = nil
    viewControllerable.popViewController(animated: true)
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
    detachTempPassword()
  }
}

extension FindPasswordCoordinator: NewPasswordListener {
  func didTapBackButtonAtNewPassword() {
    detachNewPassword()
  }
  
  func didFinishUpdatePassword() {
    listener?.didFinishUpdatePassword()
  }
}
