//
//  VerifyEmailContainer.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import UseCase

protocol VerifyEmailDependency: Dependency {
  var signUpUseCase: SignUpUseCase { get }
}

protocol VerifyEmailContainable: Containable {
  func coordinator(listener: VerifyEmailListener, userEmail: String) -> Coordinating
}

final class VerifyEmailContainer: Container<VerifyEmailDependency>, VerifyEmailContainable {
  func coordinator(listener: VerifyEmailListener, userEmail: String) -> Coordinating {
    let viewModel = VerifyEmailViewModel(useCase: dependency.signUpUseCase, email: userEmail)
    
    let coordinator = VerifyEmailCoordinator(viewModel: viewModel, userEmail: userEmail)
    coordinator.listener = listener
    return coordinator
  }
}
