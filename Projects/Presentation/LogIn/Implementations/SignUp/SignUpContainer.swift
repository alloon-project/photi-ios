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

public final class SignUpContainer: 
  Container<LogInDependency>,
  SignUpContainable,
  EnterEmailDependency,
  EnterIdDependency {
  public func coordinator(listener: SignUpListener) -> Coordinating {
    let viewModel = SignUpViewModel()
    let enterEmailContainable = EnterEmailContainer(dependency: self)
    let enterIdContainable = EnterIdContainer(dependency: self)
    
    let coordinator = SignUpCoordinator(
      viewModel: viewModel,
      enterEmailContainable: enterEmailContainable,
      enterIdContainable: enterIdContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
