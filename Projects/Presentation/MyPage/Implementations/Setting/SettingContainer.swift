//
//  SettingContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase
import ReportImpl

protocol SettingDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
}

protocol SettingContainable: Containable {
  func coordinator(listener: SettingListener) -> Coordinating
}

final class SettingContainer:
  Container<SettingDependency>,
  SettingContainable,
  ProfileEditDependency,
  ReportDependency {
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  
  public func coordinator(listener: SettingListener) -> Coordinating {
    let viewModel = SettingViewModel()
    
    let profileEdit = ProfileEditContainer(dependency: self)
    let report = ReportContainer(dependency: self)
    
    let coordinator = SettingCoordinator(
      viewModel: viewModel,
      profileEditContainable: profileEdit,
      reportContainable: report
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
