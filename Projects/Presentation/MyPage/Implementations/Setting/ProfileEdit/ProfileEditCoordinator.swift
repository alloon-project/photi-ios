//
//  ProfileEditCoordinator.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator

protocol ProfileEditListener: AnyObject {
  func didTapBackButtonAtProfileEdit()
  func didFinishWithdrawal()
  func authenticatedFailedAtProfileEdit()
}

protocol ProfileEditPresentable {
  func displayToastView()
}

final class ProfileEditCoordinator: ViewableCoordinator<ProfileEditPresentable> {
  weak var listener: ProfileEditListener?
  
  private let viewModel: ProfileEditViewModel
  
  private let changePasswordContainable: ChangePasswordContainable
  private var changePasswordCoordinator: ViewableCoordinating?
  
  private let withdrawContainable: WithdrawContainable
  private var withdrawCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ProfileEditViewModel,
    changePasswordContainable: ChangePasswordContainable,
    withdrawContainable: WithdrawContainable
  ) {
    self.viewModel = viewModel
    
    self.changePasswordContainable = changePasswordContainable
    self.withdrawContainable = withdrawContainable
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - ChangePassword
@MainActor extension ProfileEditCoordinator {
  func attachChangePassword(userName: String, userEmail: String) {
    guard changePasswordCoordinator == nil else { return }
    
    let coordinator = changePasswordContainable.coordinator(
      userName: userName,
      userEmail: userEmail,
      listener: self
    )
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.changePasswordCoordinator = coordinator
  }
  
  func detachChangePassword() {
    guard let coordinator = changePasswordCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.changePasswordCoordinator = nil
  }
}

// MARK: - Withdraw
@MainActor extension ProfileEditCoordinator {
  func attachWithdraw() {
    guard withdrawCoordinator == nil else { return }
    
    let coordinator = withdrawContainable.coordinator(listener: self)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.withdrawCoordinator = coordinator
  }
  
  func detachWithdraw() {
    guard let coordinator = withdrawCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.withdrawCoordinator = nil
  }
}

// MARK: - ProfileEditCoordinatable
extension ProfileEditCoordinator: ProfileEditCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtProfileEdit()
  }
  
  func authenticatedFailed() {
    listener?.authenticatedFailedAtProfileEdit()
  }
}

// MARK: - ChangePasswordListener
extension ProfileEditCoordinator: ChangePasswordListener {
  func didTapBackButtonAtChangePassword() {
    Task { await detachChangePassword() }
  }
  
  func didChangedPassword() {
    Task { @MainActor in
      detachChangePassword()
      guard
        let navigationController = viewControllerable.uiviewController.navigationController,
        let viewControllerables = navigationController.viewControllers as? [ViewControllerable],
        viewControllerables.count >= 3
      else { return }
      
      let remainingVCs = Array(viewControllerables.prefix(3))
      viewControllerable.setViewControllers(remainingVCs, animated: true)
      presenter.displayToastView()
    }
  }
  
  func authenticationFailedAtChangePassword() {
    listener?.authenticatedFailedAtProfileEdit()
  }
}

// MARK: - WithdrawListener
extension ProfileEditCoordinator: WithdrawListener {
  func didFinishWithdrawal() {
    listener?.didFinishWithdrawal()
  }
  
  func didTapBackButtonAtWithdraw() {
    Task { await detachWithdraw() }
  }
  
  func authenticatedFailedAtWithdraw() {
    listener?.authenticatedFailedAtProfileEdit()
  }
}
