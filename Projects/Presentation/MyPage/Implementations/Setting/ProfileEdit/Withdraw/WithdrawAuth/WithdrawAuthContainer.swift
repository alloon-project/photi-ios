//
//  WithdrawAuthContainer.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol WithdrawAuthDependency: Dependency {
  var profileEditUsecase: ProfileEditUseCase { get }
}

protocol WithdrawAuthContainable: Containable {
  func coordinator(listener: WithdrawAuthListener) -> ViewableCoordinating
}

final class WithdrawAuthContainer: Container<WithdrawAuthDependency>, WithdrawAuthContainable {
  func coordinator(listener: WithdrawAuthListener) -> ViewableCoordinating {
    let viewModel = WithdrawAuthViewModel(useCase: dependency.profileEditUsecase)
    let viewControllerable = WithdrawAuthViewController(viewModel: viewModel)
    let coordinator = WithdrawAuthCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
