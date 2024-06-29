//
//  MainContainer.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol MainDependency: Dependency { }

protocol MainContainable: Containable {
  func coordinator(listener: MainListener) -> Coordinating
}

final class MainContainer: Container<MainDependency>, MainContainable {
  func coordinator(listener: MainListener) -> Coordinating {
    let coordinator = MainCoordinator()
    coordinator.listener = listener
    return coordinator
  }
}
