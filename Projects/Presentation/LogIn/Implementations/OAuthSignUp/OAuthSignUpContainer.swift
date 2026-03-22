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
  var oauthUseCase: OAuthUseCase { get }
}

protocol OAuthSignUpContainable: Containable {
  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: OAuthSignUpListener,
    provider: String,
    idToken: String
  ) -> Coordinating
}

final class OAuthSignUpContainer:
  Container<OAuthSignUpDependency>,
  OAuthSignUpContainable,
  EnterIdDependency,
  AgreementDependency {
  var signUpUseCase: SignUpUseCase { dependency.signUpUseCase }
  var oauthUseCase: OAuthUseCase { dependency.oauthUseCase }

  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: OAuthSignUpListener,
    provider: String,
    idToken: String
  ) -> Coordinating {
    let enterIdContainable = EnterIdContainer(dependency: self)
    let agreementContainable = AgreementContainer(dependency: self)

    let coordinator = OAuthSignUpCoordinator(
      navigationControllerable: navigationControllerable,
      enterIdContainable: enterIdContainable,
      agreementContainable: agreementContainable,
      oauthUseCase: dependency.oauthUseCase,
      provider: provider,
      idToken: idToken
    )
    coordinator.listener = listener
    return coordinator
  }
}
