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
  var reportContainable: ReportContainable { get }
}

public final class MyPageContainer:
  Container<MyPageDependency>,
  MyPageContainable,
  SettingDependency,
  EndedChallengeDependency,
  ProofChallengeDependency {
  var reportContainable: ReportContainable { dependency.reportContainable }
  
  var profileEditUseCase: ProfileEditUseCase { dependency.profileEditUseCase }
  
  public func coordinator(listener: MyPageListener) -> Coordinating {
    let viewModel = MyPageViewModel(useCase: dependency.myPageUseCase)
    let settingContainable = SettingContainer(dependency: self)
    let endedChallengeContainable = EndedChallengeContainer(dependency: self)
    let proofChallengeContainable = ProofChallengeContainer(dependency: self)
    
    let coordinator = MyPageCoordinator(
      viewModel: viewModel,
      settingContainable: settingContainable,
      endedChallengeContainable: endedChallengeContainable,
      proofChallengeContainable: proofChallengeContainable
    )
    
    coordinator.listener = listener
    return coordinator
  }
}
