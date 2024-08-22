//
//  EnterIdContainer.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import UseCase

protocol EnterIdDependency: Dependency {
  var signUpUseCase: SignUpUseCase { get }
}

protocol EnterIdContainable: Containable {
  func coordinator(listener: EnterIdListener) -> Coordinating
}

final class EnterIdContainer: Container<EnterIdDependency>, EnterIdContainable {
  func coordinator(listener: EnterIdListener) -> Coordinating {
    let viewModel = EnterIdViewModel(useCase: dependency.signUpUseCase)
    
    let coordinator = EnterIdCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
