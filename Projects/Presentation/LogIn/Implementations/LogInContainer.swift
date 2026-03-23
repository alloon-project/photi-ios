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
  var oauthUseCase: OAuthUseCase { get }
  var resetPasswordContainable: ResetPasswordContainable { get }
}

public final class LogInContainer:
  Container<LogInDependency>,
  LogInContainable,
  SignUpDependency,
  OAuthSignUpDependency,
  FindIdDependency,
  FindPasswordDependency {
  var resetPasswordContainable: ResetPasswordContainable { dependency.resetPasswordContainable }
  
  public var loginUseCase: LogInUseCase { dependency.logInUseCase }
  var signUpUseCase: SignUpUseCase { dependency.signUpUseCase }
  var oauthUseCase: OAuthUseCase { dependency.oauthUseCase }

  public func coordinator(listener: LogInListener) -> ViewableCoordinating {
    let viewModel = LogInViewModel(loginUseCase: dependency.logInUseCase)
    let viewControllerable = LogInViewController(viewModel: viewModel)

    let signUp = SignUpContainer(dependency: self)
    let oAuthSignUp = OAuthSignUpContainer(dependency: self)
    let findId = FindIdContainer(dependency: self)
    let findPassword = FindPasswordContainer(dependency: self)

    let coordinator = LogInCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      signUpContainable: signUp,
      findIdContainable: findId,
      findPasswordContainable: findPassword,
      oAuthSignUpContainable: oAuthSignUp
    )
    coordinator.listener = listener
    return coordinator
  }
}
