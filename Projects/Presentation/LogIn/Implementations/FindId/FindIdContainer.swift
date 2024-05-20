//
//  FindIdContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol FindIdDependency: Dependency { }

protocol FindIdContainable: Containable {
  func coordinator(listener: FindIdListener) -> Coordinating
}

final class FindIdContainer: Container<FindIdDependency>, FindIdContainable {
  func coordinator(listener: FindIdListener) -> Coordinating {
    let coordinator = FindIdCoordinator()
    coordinator.listener = listener
    return coordinator
  }
}
