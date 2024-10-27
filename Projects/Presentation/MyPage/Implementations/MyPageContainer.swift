//
//  MyPageContainer.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import MyPage
import Report
import UseCase

public protocol MyPageDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
  var reportContainable: ReportContainable { get }
}

public final class MyPageContainer:
  Container<MyPageDependency>,
  MyPageContainable,
  SettingDependency {
  var reportContainable: ReportContainable { dependency.reportContainable }
  
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  
  public func coordinator(listener: MyPageListener) -> Coordinating {
    let viewModel = MyPageViewModel()
    let settingContainable = SettingContainer(dependency: self)
    
    let coordinator = MyPageCoordinator(
      viewModel: viewModel,
      settingContainable: settingContainable
    )
    
    coordinator.listener = listener
    return coordinator
  }
}
