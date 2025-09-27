//
//  FindPasswordContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import LogIn
import UseCase

protocol FindPasswordDependency {
  var resetPasswordContainable: ResetPasswordContainable { get }
  var loginUseCase: LogInUseCase { get }
}

protocol FindPasswordContainable: Containable {
  func coordinator(listener: FindPasswordListener) -> ViewableCoordinating
}

final class FindPasswordContainer:
  Container<FindPasswordDependency>,
  FindPasswordContainable {
  var loginUseCase: LogInUseCase { dependency.loginUseCase }
  
  func coordinator(listener: FindPasswordListener) -> ViewableCoordinating {
    let viewModel = FindPasswordViewModel(useCase: dependency.loginUseCase)
    let viewControllerable = FindPasswordViewController(viewModel: viewModel)
    
    let coordinator = FindPasswordCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel, resetPasswordContainable: dependency.resetPasswordContainable
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
