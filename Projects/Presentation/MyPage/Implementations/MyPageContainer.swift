//
//  MyPageContainer.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import MyPage

public protocol MyPageDependency: Dependency { }

public final class MyPageContainer:
  Container<MyPageDependency>,
  MyPageContainable,
  SettingDependency {
  public func coordinator(listener: MyPageListener) -> Coordinating {
    let setting = SettingContainer(dependency: self)
    let viewModel = MyPageViewModel()
    
    let coordinator = MyPageCoordinator(
      viewModel: viewModel,
      settingContainable: setting
    )
    coordinator.listener = listener
    return coordinator
  }
}
