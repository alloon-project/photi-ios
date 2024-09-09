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
  func coordinator(
    email: String,
    verificationCode: String,
    userName: String,
    listener: EnterPasswordListener
  ) -> Coordinating
}

final class EnterPasswordContainer: Container<EnterPasswordDependency>, EnterPasswordContainable {
  func coordinator(
    email: String,
    verificationCode: String,
    userName: String,
    listener: EnterPasswordListener
  ) -> Coordinating {
    let viewModel = EnterPasswordViewModel(
      useCase: dependency.signUpUseCase,
      email: email,
      verificationCode: verificationCode,
      userName: userName
    )
    
    let coordinator = EnterPasswordCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
