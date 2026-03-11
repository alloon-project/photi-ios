//
//  OAuthSignUpContainer.swift
//  LogInImpl
//
//  Created on 2026/03/02.
//

import Coordinator
import UseCase

protocol OAuthSignUpDependency {
  var signUpUseCase: SignUpUseCase { get }
}

protocol OAuthSignUpContainable: Containable {
  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: OAuthSignUpListener
  ) -> Coordinating
}

final class OAuthSignUpContainer:
  Container<OAuthSignUpDependency>,
  OAuthSignUpContainable,
  EnterIdDependency,
  AgreementDependency {
  var signUpUseCase: SignUpUseCase { dependency.signUpUseCase }

  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: OAuthSignUpListener
  ) -> Coordinating {
    let enterIdContainable = EnterIdContainer(dependency: self)
    let agreementContainable = AgreementContainer(dependency: self)

    let coordinator = OAuthSignUpCoordinator(
      navigationControllerable: navigationControllerable,
      enterIdContainable: enterIdContainable,
      agreementContainable: agreementContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
