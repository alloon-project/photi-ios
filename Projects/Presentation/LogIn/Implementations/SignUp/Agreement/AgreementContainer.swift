//
//  AgreementContainer.swift
//  LogInImpl
//
//  Created by Codex on 3/2/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import Coordinator
import UseCase

protocol AgreementDependency {
  var signUpUseCase: SignUpUseCase { get }
  var oauthUseCase: OAuthUseCase { get }
}

protocol AgreementContainable: Containable {
  func coordinator(listener: AgreementListener, password: String) -> ViewableCoordinating
}

final class AgreementContainer: Container<AgreementDependency>, AgreementContainable {
  func coordinator(listener: AgreementListener, password: String) -> ViewableCoordinating {
    let viewModel = AgreementViewModel(
      signUpUseCase: dependency.signUpUseCase,
      oauthUseCase: dependency.oauthUseCase,
      password: password
    )
    let viewControllerable = AgreementViewController(viewModel: viewModel)
    
    let coordinator = AgreementCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
