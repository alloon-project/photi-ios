//
//  VerifyEmailContainer.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol VerifyEmailDependency: Dependency { }

protocol VerifyEmailContainable: Containable {
  func coordinator(listener: VerifyEmailListener, userEmail: String) -> Coordinating
}

final class VerifyEmailContainer: Container<VerifyEmailDependency>, VerifyEmailContainable {
  func coordinator(listener: VerifyEmailListener, userEmail: String) -> Coordinating {
    let viewModel = VerifyEmailViewModel()
    
    let coordinator = VerifyEmailCoordinator(viewModel: viewModel, userEmail: userEmail)
    coordinator.listener = listener
    return coordinator
  }
}
