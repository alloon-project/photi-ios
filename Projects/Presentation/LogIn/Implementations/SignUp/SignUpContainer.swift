//
//  SignUpContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn
import UseCase

public protocol SignUpDependency: Dependency {
  var signUpUseCase: SignUpUseCase { get }
}

public final class SignUpContainer: 
  Container<SignUpDependency>,
  SignUpContainable,
  EnterEmailDependency,
  EnterIdDependency,
  EnterPasswordDependency {
  var signUpUseCase: SignUpUseCase { dependency.signUpUseCase }
  
  public func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: SignUpListener
  ) -> Coordinating {
    let enterEmailContainable = EnterEmailContainer(dependency: self)
    let enterIdContainable = EnterIdContainer(dependency: self)
    let enterPasswordContainable = EnterPasswordContainer(dependency: self)
    
    let coordinator = SignUpCoordinator(
      navigationControllerable: navigationControllerable,
      enterEmailContainable: enterEmailContainable,
      enterIdContainable: enterIdContainable,
      enterPasswordContainable: enterPasswordContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
