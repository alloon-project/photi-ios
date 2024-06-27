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
  func coordinator(listener: NewPasswordListener) -> Coordinating
}

final class NewPasswordContainer: Container<NewPasswordDependency>, NewPasswordContainable {
  func coordinator(listener: NewPasswordListener) -> Coordinating {
    let viewModel = NewPasswordViewModel()
    let coordinator = NewPasswordCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
