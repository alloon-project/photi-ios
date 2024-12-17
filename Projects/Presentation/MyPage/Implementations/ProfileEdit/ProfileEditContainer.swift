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
}

final class ProfileEditContainer:
  Container<ProfileEditDependency>,
  ProfileEditContainable,
  PasswordChangeDependency,
  ResignDependency {
  public func coordinator(listener: ProfileEditListener) -> Coordinating {
    let passwordChange = PasswordChangeContainer(dependency: self)
    let resign = ResignContainer(dependency: self)
    let viewModel = ProfileEditViewModel(useCase: dependency.profileEditUseCase)
    
    let coordinator = ProfileEditCoordinator(
      viewModel: viewModel,
      passwordChangeContainable: passwordChange, 
      resignContainable: resign
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
