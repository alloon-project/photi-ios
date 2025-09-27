//
//  FindIdContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import UseCase

protocol FindIdDependency {
  var loginUseCase: LogInUseCase { get }
}

protocol FindIdContainable: Containable {
  func coordinator(listener: FindIdListener) -> ViewableCoordinating
}

final class FindIdContainer: Container<FindIdDependency>, FindIdContainable {
  func coordinator(listener: FindIdListener) -> ViewableCoordinating {
    let viewModel = FindIdViewModel(useCase: dependency.loginUseCase)
    let viewControllerable = FindIdViewController(viewModel: viewModel)
    let coordinator = FindIdCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
