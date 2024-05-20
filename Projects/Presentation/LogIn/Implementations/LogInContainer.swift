//
//  LogInContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn

public protocol LogInDependency: Dependency {
  var signUpContainable: SignUpContainable { get }
}

public final class LogInContainer:
  Container<LogInDependency>,
  LogInContainable,
  FindPasswordDependency {
  public func coordinator(listener: LogInListener) -> Coordinating {
    let findPassword = FindPasswordContainer(dependency: self)
    
    let coordinator = LogInCoordinator(
      signUpContainable: dependency.signUpContainable,
      findPasswordContainable: findPassword
    )
    coordinator.listener = listener
    return coordinator
  }
}
