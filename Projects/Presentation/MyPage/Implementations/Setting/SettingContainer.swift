//
//  SettingContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase
import Report

protocol SettingDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
  var reportContainable: ReportContainable { get }
  var changePasswordUseCase: ChangePasswordUseCase { get }
}

protocol SettingContainable: Containable {
  func coordinator(listener: SettingListener) -> Coordinating
}

final class SettingContainer:
  Container<SettingDependency>,
  SettingContainable,
  ProfileEditDependency {
  var changePasswordUseCase: ChangePasswordUseCase { dependency.changePasswordUseCase }
  
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  
  public func coordinator(listener: SettingListener) -> Coordinating {
    let viewModel = SettingViewModel()
    
    let profileEdit = ProfileEditContainer(dependency: self)
    
    let coordinator = SettingCoordinator(
      viewModel: viewModel,
      profileEditContainable: profileEdit,
      reportContainable: dependency.reportContainable
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
