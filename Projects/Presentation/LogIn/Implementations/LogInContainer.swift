//
//  LogInContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn

public protocol LogInDependency: Dependency { }

public final class LogInContainer: Container<LogInDependency>, LogInContainable {
  public func coordinator(listener: LogInListener) -> Coordinating {
    let coordinator = LogInCoordinator()
    coordinator.listener = listener
    return coordinator
  }
}
