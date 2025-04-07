//
//  EnterPasswordContainer.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import UseCase

protocol EnterPasswordDependency: Dependency { 
  var signUpUseCase: SignUpUseCase { get }
}

protocol EnterPasswordContainable: Containable {
  func coordinator(listener: EnterPasswordListener) -> ViewableCoordinating
}

final class EnterPasswordContainer: Container<EnterPasswordDependency>, EnterPasswordContainable {
  func coordinator(listener: EnterPasswordListener) -> ViewableCoordinating {
    let viewModel = EnterPasswordViewModel(useCase: dependency.signUpUseCase)
    let viewContollerable = EnterPasswordViewController(viewModel: viewModel)
    
    let coordinator = EnterPasswordCoordinator(
      viewControllerable: viewContollerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
