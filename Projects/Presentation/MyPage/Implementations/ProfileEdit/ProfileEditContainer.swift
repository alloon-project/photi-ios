//
//  ProfileEditContainer.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import MyPage
import UseCase

public protocol ProfileEditDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
}

public final class ProfileEditContainer:
  Container<ProfileEditDependency>,
  ProfileEditContainable,
  PasswordChangeDependency,
  ResignDependency {
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  
  public func coordinator(listener: ProfileEditListener) -> Coordinating {
    let passwordChange = PasswordChangeContainer(dependency: self)
    let resign = ResignContainer(dependency: self)
    let viewModel = ProfileEditViewModel(useCase: profileEditUseCase)
    
    let coordinator = ProfileEditCoordinator(
      viewModel: viewModel,
      passwordChangeContainable: passwordChange, 
      resignContainable: resign
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
