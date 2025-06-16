//
//  ChangePasswordCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import LogIn

protocol ChangePasswordListener: AnyObject {
  func didTapBackButtonAtChangePassword()
  func didChangedPassword()
  func authenticationFailedAtChangePassword()
}

protocol ChangePasswordPresentable { }

final class ChangePasswordCoordinator: ViewableCoordinator<ChangePasswordPresentable> {
  weak var listener: ChangePasswordListener?

  private let userName: String
  private let userEmail: String
  private let viewModel: ChangePasswordViewModel
  
  private let resetPasswordContainable: ResetPasswordContainable
  private var resetPasswordCoordinator: Coordinating?
  
  init(
    userName: String,
    userEmail: String,
    viewControllerable: ViewControllerable,
    viewModel: ChangePasswordViewModel,
    resetPasswordContainable: ResetPasswordContainable
  ) {
    self.userName = userName
    self.userEmail = userEmail
    self.viewModel = viewModel
    self.resetPasswordContainable = resetPasswordContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - ChangePasswordCoordinatable
extension ChangePasswordCoordinator: ChangePasswordCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtChangePassword()
  }
  
  func didChangedPassword() {
    listener?.didChangedPassword()
  }
  
  func attachResetPassword() {
    guard resetPasswordCoordinator == nil else { return }
    
    let coordinator = resetPasswordContainable.coordinator(
      userEmail: userEmail,
      userName: userName,
      navigation: viewControllerable,
      listener: self
    )

    addChild(coordinator)
    resetPasswordCoordinator = coordinator
  }
  
  func detachResetPassword() {
    guard let coordinator = resetPasswordCoordinator else { return }
    
    removeChild(coordinator)
    resetPasswordCoordinator = nil
  }
  
  func authenticationFailed() {
    listener?.authenticationFailedAtChangePassword()
  }
}

// MARK: - ResetPasswordListener
extension ChangePasswordCoordinator: ResetPasswordListener {
  func didFinishResetPassword() {
    listener?.didChangedPassword()
  }
  
  func didCancelResetPassword() {
    detachResetPassword()
  }
}
