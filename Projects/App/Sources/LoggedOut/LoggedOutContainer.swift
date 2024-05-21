//
//  LoggedOutContainer.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn

protocol LoggedOutDependency: Dependency { 
  var logInContainable: LogInContainable { get }
}

protocol LoggedOutContainable: Containable {
  func coordinator(listener: LoggedOutListener) -> Coordinating
}

final class LoggedOutContainer: Container<LoggedOutDependency>, LoggedOutContainable {
  func coordinator(listener: LoggedOutListener) -> Coordinating {
    let coordinator = LoggedOutCoordinator(
      logInContainable: dependency.logInContainable
    )
    
    coordinator.listener = listener
    
    return coordinator
  }
}
