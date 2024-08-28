//
//  AuthCountDetailContainer.swift
//  AuthCountDetailImpl
//
//  Created by wooseob on 8/26/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol AuthCountDetailDependency: Dependency { }

public protocol AuthCountDetailContainable: Containable {
  func coordinator(listener: AuthCountDetailListener) -> Coordinating
}

public final class AuthCountDetailContainer:
  Container<AuthCountDetailDependency>,
    AuthCountDetailContainable {
  public func coordinator(listener: AuthCountDetailListener) -> Coordinating {
    let viewModel = AuthCountDetailViewModel()
    
    let coordinator = AuthCountDetailCoordinator(
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
