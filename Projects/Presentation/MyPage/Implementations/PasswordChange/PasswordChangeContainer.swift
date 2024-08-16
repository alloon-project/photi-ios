//
//  PasswordChangeContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol PasswordChangeDependency: Dependency { }

public protocol PasswordChangeContainable: Containable {
  func coordinator(listener: PasswordChangeListener) -> Coordinating
}

public final class PasswordChangeContainer:
  Container<PasswordChangeDependency>,
  PasswordChangeContainable {
  public func coordinator(listener: PasswordChangeListener) -> Coordinating {
    let viewModel = PasswordChangeViewModel()
    
    let coordinator = PasswordChangeCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
