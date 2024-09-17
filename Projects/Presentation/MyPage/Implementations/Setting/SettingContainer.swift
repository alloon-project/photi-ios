//
//  SettingContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import ReportImpl

public protocol SettingDependency: Dependency { }

public protocol SettingContainable: Containable {
  func coordinator(listener: SettingListener) -> Coordinating
}

public final class SettingContainer:
  Container<SettingDependency>,
  SettingContainable,
  ProfileEditDependency,
  ReportDependency {
  public func coordinator(listener: SettingListener) -> Coordinating {
    let profileEdit = ProfileEditContainer(dependency: self)
    let report = ReportContainer(dependency: self)
    let viewModel = SettingViewModel()
    
    let coordinator = SettingCoordinator(
      viewModel: viewModel,
      profileEditContainable: profileEdit,
      reportContainable: report
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
