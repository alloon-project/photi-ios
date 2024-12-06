//
//  ProfileEditContainer.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ProfileEditContainable: Containable {
  func coordinator(listener: ProfileEditListener) -> Coordinating
}

protocol ProfileEditDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
  var changePasswordUseCase: ChangePasswordUseCase { get }
}

final class ProfileEditContainer:
  Container<ProfileEditDependency>,
  ProfileEditContainable,
  ChangePasswordDependency,
  ResignDependency {
  var changePasswordUseCase: ChangePasswordUseCase { dependency.changePasswordUseCase}
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  
  public func coordinator(listener: ProfileEditListener) -> Coordinating {
    let changePassword = ChangePasswordContainer(dependency: self)
    let resign = ResignContainer(dependency: self)
    let viewModel = ProfileEditViewModel(useCase: dependency.profileEditUseCase)
    
    let coordinator = ProfileEditCoordinator(
      viewModel: viewModel,
      changePasswordContainable: changePassword, 
      resignContainable: resign
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
