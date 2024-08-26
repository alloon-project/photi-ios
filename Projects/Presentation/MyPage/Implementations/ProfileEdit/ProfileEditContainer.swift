//
//  ProfileEditContainer.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol ProfileEditDependency: Dependency { }

public protocol ProfileEditContainable: Containable {
  func coordinator(listener: ProfileEditListener) -> Coordinating
}

public final class ProfileEditContainer:
  Container<ProfileEditDependency>,
  ProfileEditContainable,
  PasswordChangeDependency {
  public func coordinator(listener: ProfileEditListener) -> Coordinating {
    let passwordChange = PasswordChangeContainer(dependency: self)
    let viewModel = ProfileEditViewModel()
    
    let coordinator = ProfileEditCoordinator(
      viewModel: viewModel,
      passwordChangeContainable: passwordChange
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
