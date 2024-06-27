//
//  FindPasswordContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol FindPasswordDependency: Dependency { }

protocol FindPasswordContainable: Containable {
  func coordinator(listener: FindPasswordListener) -> Coordinating
}

final class FindPasswordContainer: 
  Container<FindPasswordDependency>,
  FindPasswordContainable,
  TempPasswordDependency, 
  NewPasswordDependency {
  func coordinator(listener: FindPasswordListener) -> Coordinating {
    let viewModel = FindPasswordViewModel()
    let tempPasswordContainable = TempPasswordContainer(dependency: self)
    let newPasswordContainable = NewPasswordContainer(dependency: self)
    let coordinator = FindPasswordCoordinator(
      viewModel: viewModel,
      tempPasswordContainable: tempPasswordContainable, 
      newPasswordContainable: newPasswordContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
