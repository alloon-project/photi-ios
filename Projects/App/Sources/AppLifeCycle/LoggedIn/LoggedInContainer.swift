//
//  LoggedInContainer.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol LoggedInDependency: Dependency { }

protocol LoggedInContainable: Containable {
  func coordinator(listener: LoggedInListener) -> Coordinater
}

final class LoggedInContainer: Container<LoggedInDependency>, LoggedInContainable {
  func coordinator(listener: LoggedInListener) -> Coordinater {
    let coordinator = LoggedInCoordinator()
    coordinator.listener = listener
    return coordinator
  }
}
