//
//  EnterPasswordContainer.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol EnterPasswordDependency: Dependency { }

protocol EnterPasswordContainable: Containable {
  func coordinator(listener: EnterPasswordListener) -> Coordinating
}

final class EnterPasswordContainer: Container<EnterPasswordDependency>, EnterPasswordContainable {
  func coordinator(listener: EnterPasswordListener) -> Coordinating {
    let viewModel = EnterPasswordViewModel()
    
    let coordinator = EnterPasswordCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
