//
//  ChangePasswordContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import LogIn
import UseCase

protocol ChangePasswordDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
  var resetPasswordContainable: ResetPasswordContainable { get }
}

protocol ChangePasswordContainable: Containable {
  func coordinator(
    userName: String,
    userEmail: String,
    listener: ChangePasswordListener
  ) -> ViewableCoordinating
}

final class ChangePasswordContainer:
  Container<ChangePasswordDependency>,
  ChangePasswordContainable {
  func coordinator(
    userName: String,
    userEmail: String,
    listener: ChangePasswordListener
  ) -> ViewableCoordinating {
    let viewModel = ChangePasswordViewModel(useCase: dependency.profileEditUseCase)
    let viewControllerable = ChangePasswordViewController(viewModel: viewModel)
    
    let coordinator = ChangePasswordCoordinator(
      userName: userName,
      userEmail: userEmail,
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      resetPasswordContainable: dependency.resetPasswordContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
