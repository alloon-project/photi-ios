//
//  WithdrawCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol WithdrawListener: AnyObject {
  func didTapBackButtonAtWithdraw()
  func didFinishWithdrawal()
  func authenticatedFailedAtWithdraw()
}

protocol WithdrawPresentable { }

final class WithdrawCoordinator: ViewableCoordinator<WithdrawPresentable> {
  weak var listener: WithdrawListener?

  private let viewModel: WithdrawViewModel
  
  private let withdrawAuthContainable: WithdrawAuthContainable
  private var withdrawAuthCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: WithdrawViewModel,
    withdrawAuthContainable: WithdrawAuthContainable
  ) {
    self.viewModel = viewModel
    self.withdrawAuthContainable = withdrawAuthContainable
    super.init(viewControllerable)
    viewModel.coodinator = self
  }
}

// MARK: - Coordinatable
extension WithdrawCoordinator: WithdrawCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtWithdraw()
  }
  
  func attachWithdrawAuth() {
    guard withdrawAuthCoordinator == nil else { return }
    
    let coordinator = withdrawAuthContainable.coordinator(listener: self)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.withdrawAuthCoordinator = coordinator
  }
  
  func detachResignPassword() {
    guard let coordinator = withdrawAuthCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.withdrawAuthCoordinator = nil
  }
  
  func didTapCancelButton() {
    listener?.didTapBackButtonAtWithdraw()
  }
}

// MARK: - WithdrawAuthListener
extension WithdrawCoordinator: WithdrawAuthListener {
  func didTapBackButtonAtWithdrawAuth() {
    detachResignPassword()
  }
  
  func didFinishWithdrawal() {
    listener?.didFinishWithdrawal()
  }
  
  func authenticatedFailedAtWithdrawAuth() {
    listener?.authenticatedFailedAtWithdraw()
  }
}
