//
//  MyPageContainer.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Challenge
import Core
import MyPage
import Report
import UseCase

public protocol MyPageDependency: Dependency {
  var challengeContainable: ChallengeContainable { get }
  var myPageUseCase: MyPageUseCase { get }
  var profileEditUseCase: ProfileEditUseCase { get }
  var changePasswordUseCase: ChangePasswordUseCase { get }
  var reportContainable: ReportContainable { get }
}

public final class MyPageContainer:
  Container<MyPageDependency>,
  MyPageContainable,
  SettingDependency,
  EndedChallengeDependency,
  FeedHistoryDependency,
  FeedsByDateDependency {
  var challengeContainable: ChallengeContainable { dependency.challengeContainable }
  
  var changePasswordUseCase: ChangePasswordUseCase { dependency.changePasswordUseCase }
  var reportContainable: ReportContainable { dependency.reportContainable }
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  var myPageUseCase: MyPageUseCase { dependency.myPageUseCase }
  
  public func coordinator(listener: MyPageListener) -> ViewableCoordinating {
    let viewModel = MyPageViewModel(useCase: dependency.myPageUseCase)
    let viewControllerable = MyPageViewController(viewModel: viewModel)
    
    let settingContainable = SettingContainer(dependency: self)
    let endedChallengeContainable = EndedChallengeContainer(dependency: self)
    let feedHistoryContainable = FeedHistoryContainer(dependency: self)
    let feedsByDateContainable = FeedsByDateContainer(dependency: self)
    
    let coordinator = MyPageCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      settingContainable: settingContainable,
      endedChallengeContainable: endedChallengeContainable,
      feedHistoryContainable: feedHistoryContainable,
      feedsByDateContainable: feedsByDateContainable
    )
    
    coordinator.listener = listener
    return coordinator
  }
}
