//
//  ResetPasswordContainer.swift
//  LogIn
//
//  Created by jung on 6/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import LogIn
import UseCase

public protocol ResetPasswordDependency: Dependency {
  var logInUseCase: LogInUseCase { get }
}

public final class ResetPasswordContainer:
  Container<ResetPasswordDependency>,
  ResetPasswordContainable,
  TempPasswordDependency,
  NewPasswordDependency {
  var loginUseCase: LogInUseCase { dependency.logInUseCase }
  
  public func coordinator(
    userEmail: String,
    userName: String,
    navigation: ViewControllerable,
    listener: ResetPasswordListener
  ) -> Coordinating {
    let tempPasswordContainable = TempPasswordContainer(dependency: self)
    let newPasswordContainable = NewPasswordContainer(dependency: self)
    
    let coordinator = ResetPasswordCoordinator(
      userEmail: userEmail,
      userName: userName,
      navigation: navigation,
      tempPasswordContainable: tempPasswordContainable,
      newPasswordContainable: newPasswordContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
