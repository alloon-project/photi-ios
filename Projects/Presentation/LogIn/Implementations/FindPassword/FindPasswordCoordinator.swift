//
//  FindPasswordCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import LogIn

protocol FindPasswordListener: AnyObject {
  func didTapBackButtonAtFindPassword()
  func didFinishUpdatePassword()
}

protocol FindPasswordPresentable { }

final class FindPasswordCoordinator: ViewableCoordinator<FindPasswordPresentable> {
  weak var listener: FindPasswordListener?

  private let viewModel: FindPasswordViewModel
  
  private let resetPasswordContainable: ResetPasswordContainable
  private var resetPasswordCoordinator: Coordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FindPasswordViewModel,
    resetPasswordContainable: ResetPasswordContainable
  ) {
    self.viewModel = viewModel
    self.resetPasswordContainable = resetPasswordContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - FindPasswordCoordinatable
extension FindPasswordCoordinator: FindPasswordCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtFindPassword()
  }
  
  func attachResetPassword(userEmail: String, userName: String) {
    guard resetPasswordCoordinator == nil else { return }
    
    let coordinator = resetPasswordContainable.coordinator(
      userEmail: userEmail,
      userName: userName,
      navigation: viewControllerable,
      listener: self
    )
    addChild(coordinator)
    self.resetPasswordCoordinator = coordinator
  }
  
  func detachResetPassword() {
    guard let coordinator = resetPasswordCoordinator else { return }
    removeChild(coordinator)
    self.resetPasswordCoordinator = nil
  }
}

// MARK: - ResetPasswordListener
extension FindPasswordCoordinator: ResetPasswordListener {
  func didCancelResetPassword() {
    detachResetPassword()
  }
  
  func didFinishResetPassword() {
    listener?.didFinishUpdatePassword()
  }
}
