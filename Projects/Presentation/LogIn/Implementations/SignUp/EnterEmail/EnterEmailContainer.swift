//
//  EnterEmailContainer.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol EnterEmailDependency: Dependency { }

protocol EnterEmailContainable: Containable {
  func coordinator(listener: EnterEmailListener) -> Coordinating
}

final class EnterEmailContainer: Container<EnterEmailDependency>, EnterEmailContainable {
  func coordinator(listener: EnterEmailListener) -> Coordinating {
    let viewModel = EnterEmailViewModel()
    
    let coordinator = EnterEmailCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
