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
  var signUpUseCase: SignUpUseCase { get }
  var logInUseCase: LogInUseCase { get }
  var findIdUseCase: FindIdUseCase { get }
  var findPasswordUseCase: FindPasswordUseCase { get }
}

public final class LogInContainer:
  Container<LogInDependency>,
  LogInContainable,
  SignUpDependency,
  FindIdDependency,
  FindPasswordDependency {
  public var signUpUseCase: SignUpUseCase { dependency.signUpUseCase }
  var loginUseCase: LogInUseCase { dependency.logInUseCase }
  var findIdUseCase: FindIdUseCase { dependency.findIdUseCase }
  var findPasswordUseCase: FindPasswordUseCase { dependency.findPasswordUseCase }

  public func coordinator(listener: LogInListener) -> ViewableCoordinating {
    let viewModel = LogInViewModel(useCase: dependency.logInUseCase)
    let viewControllerable = LogInViewController(viewModel: viewModel)

    let signUp = SignUpContainer(dependency: self)
    let findId = FindIdContainer(dependency: self)
    let findPassword = FindPasswordContainer(dependency: self)
    
    let coordinator = LogInCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      signUpContainable: signUp,
      findIdContainable: findId,
      findPasswordContainable: findPassword
    )
    coordinator.listener = listener
    return coordinator
  }
}
