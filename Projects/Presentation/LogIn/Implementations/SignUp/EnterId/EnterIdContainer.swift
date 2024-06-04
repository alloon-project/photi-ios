//
//  EnterIdContainer.swift
//  LogInImpl
//
//  Created by jung on 6/4/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol EnterIdDependency: Dependency { }

protocol EnterIdContainable: Containable {
  func coordinator(listener: EnterIdListener) -> Coordinating
}

final class EnterIdContainer: Container<EnterIdDependency>, EnterIdContainable {
  func coordinator(listener: EnterIdListener) -> Coordinating {
    let viewModel = EnterIdViewModel()
    
    let coordinator = EnterIdCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
