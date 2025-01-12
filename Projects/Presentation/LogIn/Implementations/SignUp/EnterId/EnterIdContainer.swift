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
  func coordinator(listener: EnterIdListener) -> ViewableCoordinating
}

final class EnterIdContainer: Container<EnterIdDependency>, EnterIdContainable {
  func coordinator(listener: EnterIdListener) -> ViewableCoordinating {
    let viewModel = EnterIdViewModel(useCase: dependency.signUpUseCase)
    let viewControllerable = EnterIdViewController(viewModel: viewModel)
    let coordinator = EnterIdCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
