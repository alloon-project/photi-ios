//
//  NewPasswordContainer.swift
//  LogInImpl
//
//  Created by wooseob on 6/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol NewPasswordDependency: Dependency { }

protocol NewPasswordContainable: Containable {
  func coordinator(listener: NewPasswordListener) -> ViewableCoordinating
}

final class NewPasswordContainer: Container<NewPasswordDependency>, NewPasswordContainable {
  func coordinator(listener: NewPasswordListener) -> ViewableCoordinating {
    let viewModel = NewPasswordViewModel()
    let viewControllerable = NewPasswordViewController(viewModel: viewModel)
    let coordinator = NewPasswordCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
