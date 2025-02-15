//
//  TempPasswordContainer.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import UseCase

protocol TempPasswordDependency: Dependency {
  var findPasswordUseCase: FindPasswordUseCase { get }
  var loginUseCase: LogInUseCase { get }
}

protocol TempPasswordContainable: Containable {
  func coordinator(
    listener: TempPasswordListener,
    userEmail: String,
    userName: String
  ) -> ViewableCoordinating
}

final class TempPasswordContainer:
  Container<TempPasswordDependency>,
  TempPasswordContainable {
  func coordinator(
    listener: TempPasswordListener,
    userEmail: String,
    userName: String
  ) -> ViewableCoordinating {
    let viewModel = TempPasswordViewModel(
      findPasswordUseCase: dependency.findPasswordUseCase,
      loginUseCase: dependency.loginUseCase,
      email: userEmail,
      name: userName
    )
    let viewControllerable = TempPasswordViewController(viewModel: viewModel)
    
    let coordinator = TempPasswordCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      userEmail: userEmail
    )
    coordinator.listener = listener
    return coordinator
  }
}
