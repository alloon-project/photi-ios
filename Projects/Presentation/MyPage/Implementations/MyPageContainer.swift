//
//  MyPageContainer.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import MyPage
import UseCase

public protocol MyPageDependency: Dependency {
  var profileEditUseCase: ProfileEditUseCase { get }
}

public final class MyPageContainer:
  Container<MyPageDependency>,
  MyPageContainable,
  SettingDependency,
  FinishedChallengeDependency {
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  
  public func coordinator(listener: MyPageListener) -> Coordinating {
    let viewModel = MyPageViewModel()
    let settingContainable = SettingContainer(dependency: self)
    let finishedChallengeContainable = FinishedChallengeContainer(dependency: self)
    
    let coordinator = MyPageCoordinator(
      viewModel: viewModel,
      settingContainable: settingContainable,
      finishedChallengeContainable: finishedChallengeContainable
    )
    
    coordinator.listener = listener
    return coordinator
  }
}
