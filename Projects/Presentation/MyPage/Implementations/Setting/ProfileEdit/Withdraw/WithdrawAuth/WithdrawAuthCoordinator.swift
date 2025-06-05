//
//  WithdrawAuthCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import LogIn

protocol WithdrawAuthListener: AnyObject {
  func didTapBackButtonAtWithdrawAuth()
  func didFinishWithdrawal()
}

protocol WithdrawAuthPresentable { }

final class WithdrawAuthCoordinator: ViewableCoordinator<WithdrawAuthPresentable>, WithdrawAuthCoordinatable {
  weak var listener: WithdrawAuthListener?
  
  private let viewModel: any WithdrawAuthViewModelType
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: WithdrawAuthViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  func isRequestSucceed() {
    listener?.didFinishWithdrawal()
  }
  func didTapBackButton() {
    listener?.didTapBackButtonAtWithdrawAuth()
  }
}
