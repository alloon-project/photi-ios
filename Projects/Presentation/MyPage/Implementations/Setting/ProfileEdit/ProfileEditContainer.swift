//
//  ProfileEditContainer.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import LogIn
import UseCase

protocol ProfileEditDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
  var resetPasswordContainable: ResetPasswordContainable { get }
}

protocol ProfileEditContainable: Containable {
  func coordinator(listener: ProfileEditListener) -> ViewableCoordinating
}

final class ProfileEditContainer:
  Container<ProfileEditDependency>,
  ProfileEditContainable,
  ChangePasswordDependency,
  WithdrawDependency {
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  var resetPasswordContainable: ResetPasswordContainable { dependency.resetPasswordContainable }
  
  func coordinator(listener: ProfileEditListener) -> ViewableCoordinating {
    let viewModel = ProfileEditViewModel(useCase: dependency.profileEditUseCase)
    let viewControllerable = ProfileEditViewController(viewModel: viewModel)
    
    let changePassword = ChangePasswordContainer(dependency: self)
    let withdraw = WithdrawContainer(dependency: self)
    
    let coordinator = ProfileEditCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      changePasswordContainable: changePassword, 
      withdrawContainable: withdraw
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
