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
  var myPageUseCase: MyPageUseCase { get }
  var profileEditUseCase: ProfileEditUseCase { get }
  var changePasswordUseCase: ChangePasswordUseCase { get }
  var reportContainable: ReportContainable { get }
  var endedChallengeUseCase: EndedChallengeUseCase { get }
  var feedUseCase: FeedUseCase { get }
  var resignUsecase: ResignUseCase { get }
}

public final class MyPageContainer:
  Container<MyPageDependency>,
  MyPageContainable,
  SettingDependency,
  EndedChallengeDependency,
  FeedHistoryDependency {
  var changePasswordUseCase: ChangePasswordUseCase { dependency.changePasswordUseCase }
  
  var reportContainable: ReportContainable { dependency.reportContainable }
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  var endedChallengeUseCase: EndedChallengeUseCase { dependency.endedChallengeUseCase }
  var feedUseCase: FeedUseCase { dependency.feedUseCase }
  var resignUseCase: ResignUseCase { dependency.resignUsecase }

  public func coordinator(
    listener: MyPageListener
  ) -> ViewableCoordinating {
    let viewModel = MyPageViewModel(useCase: dependency.myPageUseCase)
    let viewControllerable = MyPageViewController(viewModel: viewModel)
    
    let settingContainable = SettingContainer(dependency: self)
    let endedChallengeContainable = EndedChallengeContainer(dependency: self)
    let FeedHistoryContainable = FeedHistoryContainer(dependency: self)
    
    let coordinator = MyPageCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      settingContainable: settingContainable,
      endedChallengeContainable: endedChallengeContainable,
      FeedHistoryContainable: FeedHistoryContainable
    )
    
    coordinator.listener = listener
    return coordinator
  }
}
