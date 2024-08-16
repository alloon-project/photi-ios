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
  ProfileEditContainable {
  public func coordinator(listener: ProfileEditListener) -> Coordinating {
    let viewModel = ProfileEditViewModel()
    
    let coordinator = ProfileEditCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
