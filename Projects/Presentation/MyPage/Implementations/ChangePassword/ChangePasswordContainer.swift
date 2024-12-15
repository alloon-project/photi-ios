//
//  ChangePasswordContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

public protocol ChangePasswordDependency: Dependency {
  var changePasswordUseCase: ChangePasswordUseCase { get }
}

public protocol ChangePasswordContainable: Containable {
  func coordinator(listener: ChangePasswordListener) -> Coordinating
}

public final class ChangePasswordContainer:
  Container<ChangePasswordDependency>,
  ChangePasswordContainable {
  public func coordinator(listener: ChangePasswordListener) -> Coordinating {
    let viewModel = ChangePasswordViewModel(useCase: dependency.changePasswordUseCase)
    
    let coordinator = ChangePasswordCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
