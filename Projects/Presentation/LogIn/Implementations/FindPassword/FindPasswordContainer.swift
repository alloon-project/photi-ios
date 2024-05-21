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

final class FindPasswordContainer: Container<FindPasswordDependency>, FindPasswordContainable {
  func coordinator(listener: FindPasswordListener) -> Coordinating {
    let coordinator = FindPasswordCoordinator()
    coordinator.listener = listener
    return coordinator
  }
}
