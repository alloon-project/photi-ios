//
//  LogInContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn
import UseCase

public protocol LogInDependency: Dependency {
  var signUpContainable: SignUpContainable { get }
  var logInUseCase: LogInUseCase { get }
  var findPasswordUseCase: FindPasswordUseCase { get }
}

public final class LogInContainer:
  Container<LogInDependency>,
  LogInContainable,
  FindIdDependency,
  FindPasswordDependency {
  var findPasswordUseCase: FindPasswordUseCase { dependency.findPasswordUseCase }

  public func coordinator(listener: LogInListener) -> Coordinating {
    let findId = FindIdContainer(dependency: self)
    let findPassword = FindPasswordContainer(dependency: self)
    let viewModel = LogInViewModel(useCase: dependency.logInUseCase)
    
    let coordinator = LogInCoordinator(
      viewModel: viewModel,
      signUpContainable: dependency.signUpContainable,
      findIdContainable: findId,
      findPasswordContainable: findPassword
    )
    coordinator.listener = listener
    return coordinator
  }
}
