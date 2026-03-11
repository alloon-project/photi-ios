//
//  EnterPasswordContainer.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator

protocol EnterPasswordDependency { }

protocol EnterPasswordContainable: Containable {
  func coordinator(listener: EnterPasswordListener) -> ViewableCoordinating
}

final class EnterPasswordContainer: Container<EnterPasswordDependency>, EnterPasswordContainable {
  func coordinator(listener: EnterPasswordListener) -> ViewableCoordinating {
    let viewModel = EnterPasswordViewModel()
    let viewContollerable = EnterPasswordViewController(viewModel: viewModel)
    
    let coordinator = EnterPasswordCoordinator(
      viewControllerable: viewContollerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
