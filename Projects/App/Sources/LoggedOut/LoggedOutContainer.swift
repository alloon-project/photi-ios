//
//  LoggedOutContainer.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol LoggedOutDependency: Dependency { }

protocol LoggedOutContainable: Containable {
  func coordinator(listener: LoggedOutListener) -> Coordinating
}

final class LoggedOutContainer: Container<LoggedOutDependency>, LoggedOutContainable {
  func coordinator(listener: LoggedOutListener) -> Coordinating {
    let coordinator = LoggedOutCoordinator()
    coordinator.listener = listener
    
    return coordinator
  }
}
