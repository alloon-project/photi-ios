//
//  EnterEmailContainer.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import UseCase

protocol EnterEmailDependency {
  var signUpUseCase: SignUpUseCase { get }
}

protocol EnterEmailContainable: Containable {
  func coordinator(listener: EnterEmailListener) -> ViewableCoordinating
}

final class EnterEmailContainer:
  Container<EnterEmailDependency>,
  EnterEmailContainable,
  VerifyEmailDependency {
  var signUpUseCase: SignUpUseCase { dependency.signUpUseCase }
  
  func coordinator(listener: EnterEmailListener) -> ViewableCoordinating {
    let viewModel = EnterEmailViewModel(useCase: signUpUseCase)
    let viewControllerable = EnterEmailViewController(viewModel: viewModel)
    let verifyEmailContainable = VerifyEmailContainer(dependency: self)
    
    let coordinator = EnterEmailCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      verifyEmailContainable: verifyEmailContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
