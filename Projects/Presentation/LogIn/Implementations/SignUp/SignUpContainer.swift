//
//  SignUpContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import LogIn
import UseCase

protocol SignUpDependency {
  var signUpUseCase: SignUpUseCase { get }
  var oauthUseCase: OAuthUseCase { get }
}

protocol SignUpContainable: Containable {
  func coordinator(navigationControllerable: NavigationControllerable, listener: SignUpListener) -> Coordinating
}

final class SignUpContainer:
  Container<SignUpDependency>,
  SignUpContainable,
  EnterEmailDependency,
  EnterIdDependency,
  EnterPasswordDependency,
  AgreementDependency {
  var signUpUseCase: SignUpUseCase { dependency.signUpUseCase }
  var oauthUseCase: OAuthUseCase { dependency.oauthUseCase }
  
  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: SignUpListener
  ) -> Coordinating {
    let enterEmailContainable = EnterEmailContainer(dependency: self)
    let enterIdContainable = EnterIdContainer(dependency: self)
    let enterPasswordContainable = EnterPasswordContainer(dependency: self)
    let agreementContainable = AgreementContainer(dependency: self)
    
    let coordinator = SignUpCoordinator(
      navigationControllerable: navigationControllerable,
      enterEmailContainable: enterEmailContainable,
      enterIdContainable: enterIdContainable,
      enterPasswordContainable: enterPasswordContainable,
      agreementContainable: agreementContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
