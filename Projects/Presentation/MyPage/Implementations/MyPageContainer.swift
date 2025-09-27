//
//  MyPageContainer.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import Challenge
import LogIn
import MyPage
import Report
import UseCase

public protocol MyPageDependency {
  var challengeContainable: ChallengeContainable { get }
  var myPageUseCase: MyPageUseCase { get }
  var profileEditUseCase: ProfileEditUseCase { get }
  var resetPasswordContainable: ResetPasswordContainable { get }
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
  
  var reportContainable: ReportContainable { dependency.reportContainable }
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  var resetPasswordContainable: ResetPasswordContainable { dependency.resetPasswordContainable }
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
