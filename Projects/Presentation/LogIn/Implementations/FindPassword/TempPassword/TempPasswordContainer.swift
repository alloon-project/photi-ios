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
  // 부모에게 요구하는 의존성들을 정의합니다. ex) FindIdUseCase
  var findPasswordUseCase: FindPasswordUseCase { get }
  var loginUseCase: LogInUseCase { get }
}

protocol TempPasswordContainable: Containable {
  func coordinator(
    listener: TempPasswordListener,
    userEmail: String,
    userName: String
  ) -> Coordinating
}

final class TempPasswordContainer:
  Container<TempPasswordDependency>,
  TempPasswordContainable {
  var findPasswordUseCase: FindPasswordUseCase { dependency.findPasswordUseCase }
  var loginUseCase: LogInUseCase { dependency.loginUseCase }
  
  func coordinator(
    listener: TempPasswordListener,
    userEmail: String,
    userName: String
  ) -> Coordinating {
    let viewModel = TempPasswordViewModel(
      findPasswordUseCase: findPasswordUseCase,
      loginUseCase: loginUseCase,
      email: userEmail,
      name: userName
    )
    
    let coordinator = TempPasswordCoordinator(viewModel: viewModel, userEmail: userEmail)
    coordinator.listener = listener
    return coordinator
  }
}
