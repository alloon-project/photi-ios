//
//  SignUpContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn

public protocol SignUpDependency: Dependency { }

public final class SignUpContainer: Container<LogInDependency>, SignUpContainable {
  public func coordinator(listener: SignUpListener) -> Coordinating {
    let coordinator = SignUpCoordinator()
    coordinator.listener = listener
    return coordinator
  }
}
