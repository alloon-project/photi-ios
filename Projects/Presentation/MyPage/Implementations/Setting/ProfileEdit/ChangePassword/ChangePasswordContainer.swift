//
//  ChangePasswordContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ChangePasswordDependency: Dependency {
  var changePasswordUseCase: ChangePasswordUseCase { get }
}

protocol ChangePasswordContainable: Containable {
  func coordinator(listener: ChangePasswordListener) -> ViewableCoordinating
}

final class ChangePasswordContainer:
  Container<ChangePasswordDependency>,
  ChangePasswordContainable {
  func coordinator(listener: ChangePasswordListener) -> ViewableCoordinating {
    let viewModel = ChangePasswordViewModel(useCase: dependency.changePasswordUseCase)
    let viewControllerable = ChangePasswordViewController(viewModel: viewModel)
    
    let coordinator = ChangePasswordCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
