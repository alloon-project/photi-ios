//
//  ResetPasswordCoordinator.swift
//  LogIn
//
//  Created by jung on 6/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import LogIn

final class ResetPasswordCoordinator: Coordinator {
  private let userEmail: String
  private let userName: String
  private let navigation: ViewControllerable
  weak var listener: ResetPasswordListener?
  
  // MARK: - Temp Password
  private let tempPasswordContainable: TempPasswordContainable
  private var tempPasswordCoordinator: ViewableCoordinating?
  
  // MARK: - New Password
  private let newPasswordContainable: NewPasswordContainable
  private var newPasswordCoordinator: ViewableCoordinating?
  
  init(
    userEmail: String,
    userName: String,
    navigation: ViewControllerable,
    tempPasswordContainable: TempPasswordContainable,
    newPasswordContainable: NewPasswordContainable
  ) {
    self.userEmail = userEmail
    self.userName = userName
    self.navigation = navigation
    self.tempPasswordContainable = tempPasswordContainable
    self.newPasswordContainable = newPasswordContainable
    super.init()
  }
  
  override func start() {
    Task { await attachTempPassword(userEmail: userEmail, userName: userName) }
  }
  
  override func stop() {
    Task {
      await detachNewPassword(animated: false)
      await detachTempPassword(animated: false)
    }
  }
}

// MARK: - Temp Password
@MainActor private extension ResetPasswordCoordinator {
  func attachTempPassword(userEmail: String, userName: String) {
    guard tempPasswordCoordinator == nil else { return }
    
    let coordinater = tempPasswordContainable.coordinator(
      listener: self,
      userEmail: userEmail,
      userName: userName
    )
    addChild(coordinater)
    navigation.pushViewController(coordinater.viewControllerable, animated: true)
    self.tempPasswordCoordinator = coordinater
  }
  
  func detachTempPassword(animated: Bool) {
    guard let coordinater = tempPasswordCoordinator else { return }
    
    self.tempPasswordCoordinator = nil
    navigation.popViewController(animated: animated)
    removeChild(coordinater)
  }
}

// MARK: - New Password
@MainActor private extension ResetPasswordCoordinator {
  func attatchNewPassword() {
    guard newPasswordCoordinator == nil else { return }
    
    let coordinater = newPasswordContainable.coordinator(listener: self)
    addChild(coordinater)
    navigation.pushViewController(coordinater.viewControllerable, animated: true)
    self.newPasswordCoordinator = coordinater
  }
  
  func detachNewPassword(animated: Bool) {
    guard let coordinater = newPasswordCoordinator else { return }
    
    self.newPasswordCoordinator = nil
    navigation.popViewController(animated: animated)
    removeChild(coordinater)
  }
}

extension ResetPasswordCoordinator: TempPasswordListener {
  func didFinishTempPassword() {
    Task { await attatchNewPassword() }
  }
  
  func didTapBackButtonAtTempPassword() {
    Task { await detachTempPassword(animated: true) }
    listener?.didCancelResetPassword()
  }
}

extension ResetPasswordCoordinator: NewPasswordListener {
  func didTapBackButtonAtNewPassword() {
    Task { await detachTempPassword(animated: true) }
  }
  
  func didFinishUpdatePassword() {
    listener?.didFinishResetPassword()
  }
}
