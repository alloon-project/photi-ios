//
//  LogInContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import LogIn
import UseCase

public protocol LogInDependency {
  var signUpUseCase: SignUpUseCase { get }
  var logInUseCase: LogInUseCase { get }
  var resetPasswordContainable: ResetPasswordContainable { get }
}

public final class LogInContainer:
  Container<LogInDependency>,
  LogInContainable,
  SignUpDependency,
  FindIdDependency,
  FindPasswordDependency {
  var resetPasswordContainable: ResetPasswordContainable { dependency.resetPasswordContainable }
  
  public var loginUseCase: LogInUseCase { dependency.logInUseCase }
  var signUpUseCase: SignUpUseCase { dependency.signUpUseCase }

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
