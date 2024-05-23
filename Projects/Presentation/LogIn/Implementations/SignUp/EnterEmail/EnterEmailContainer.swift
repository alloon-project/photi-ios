//
//  EnterEmailContainer.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol EnterEmailDependency: Dependency { }

protocol EnterEmailContainable: Containable {
  func coordinator(listener: EnterEmailListener) -> Coordinating
}

final class EnterEmailContainer:
  Container<EnterEmailDependency>,
  EnterEmailContainable,
  VerifyEmailDependency {
  func coordinator(listener: EnterEmailListener) -> Coordinating {
    let viewModel = EnterEmailViewModel()
    let verifyEmailContainable = VerifyEmailContainer(dependency: self)
    
    let coordinator = EnterEmailCoordinator(
      viewModel: viewModel,
      verifyEmailContainable: verifyEmailContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
