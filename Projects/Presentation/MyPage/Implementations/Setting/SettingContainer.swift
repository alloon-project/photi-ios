//
//  SettingContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import MyPage
import UseCase
import ReportImpl

public protocol SettingDependency: Dependency {
  var profileEditContainable: ProfileEditContainable { get }
}

public final class SettingContainer:
  Container<SettingDependency>,
  SettingContainable,
  ReportDependency {
  public func coordinator(listener: SettingListener) -> Coordinating {
    let viewModel = SettingViewModel()
    
    let report = ReportContainer(dependency: self)
    
    let coordinator = SettingCoordinator(
      viewModel: viewModel,
      profileEditContainable: dependency.profileEditContainable,
      reportContainable: report
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
