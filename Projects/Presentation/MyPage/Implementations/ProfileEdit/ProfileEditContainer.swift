//
//  ProfileEditContainer.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ProfileEditDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
  var changePasswordUseCase: ChangePasswordUseCase { get }
  var resignUsecase: ResignUseCase { get }
}

protocol ProfileEditContainable: Containable {
  func coordinator(listener: ProfileEditListener) -> ViewableCoordinating
}

final class ProfileEditContainer:
  Container<ProfileEditDependency>,
  ProfileEditContainable,
  ChangePasswordDependency,
  ResignDependency {
  var resignUsecase: ResignUseCase { dependency.resignUsecase }
  var changePasswordUseCase: ChangePasswordUseCase { dependency.changePasswordUseCase }
  
  func coordinator(listener: ProfileEditListener) -> ViewableCoordinating {
    let viewModel = ProfileEditViewModel(useCase: dependency.profileEditUseCase)
    let viewControllerable = ProfileEditViewController(viewModel: viewModel)
    
    let changePassword = ChangePasswordContainer(dependency: self)
    let resign = ResignContainer(dependency: self)
    
    let coordinator = ProfileEditCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      changePasswordContainable: changePassword, 
      resignContainable: resign
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
