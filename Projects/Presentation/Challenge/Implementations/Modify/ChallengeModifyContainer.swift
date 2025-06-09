//
//  ChallengeModifyContainer.swift
//  Presentation
//
//  Created by 임우섭 on 5/17/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Challenge
import Core
import UseCase
import Kingfisher

protocol ChallengeModifyDependency: Dependency {
  var organizeUseCase: OrganizeUseCase { get }
}

protocol ChallengeModifyContainable: Containable {
  func coordinator(
    listener: ModifyChallengeListener,
    viewPresentationMdoel: ModifyPresentationModel,
    challengeId: Int
  ) async -> ViewableCoordinating
}

final class ChallengeModifyContainer:
  Container<ChallengeModifyDependency>,
  ChallengeModifyContainable,
  ChallengeNameDependency,
  ChallengeGoalDependency,
  ChallengeCoverDependency,
  ChallengeRuleDependency,
  ChallengeHashtagDependency {
  var organizeUseCase: OrganizeUseCase { dependency.organizeUseCase }

  func coordinator(
    listener: ModifyChallengeListener,
    viewPresentationMdoel: ModifyPresentationModel,
    challengeId: Int
  ) async -> ViewableCoordinating {
      await organizeUseCase.configureChallengePayload(.name, value: viewPresentationMdoel.title)
      await organizeUseCase.configureChallengePayload(.goal, value: viewPresentationMdoel.goal)
      await organizeUseCase.configureChallengePayload(.proveTime, value: viewPresentationMdoel.verificationTime)
      await organizeUseCase.configureChallengePayload(.endDate, value: viewPresentationMdoel.deadLine)
      await organizeUseCase.configureChallengePayload(.rules, value: viewPresentationMdoel.rules)
      await organizeUseCase.configureChallengePayload(.hashtags, value: viewPresentationMdoel.hashtags)
      await organizeUseCase.configureChallengePayload(.image, value: viewPresentationMdoel.imageUrlString)
    
    let viewModel = ChallengeModifyViewModel(
      useCase: organizeUseCase,
      challengeId: challengeId
    )
    let viewControllerable = await ChallengeModifyViewController(viewModel: viewModel)
    
    let modifyChallengeNameContainable = ChallengeNameContainer(dependency: self)
    let modifyChallengeGoalContainable = ChallengeGoalContainer(dependency: self)
    let modifyChallengeCoverContainable = ChallengeCoverContainer(dependency: self)
    let modifyChallengeRuleContainable = ChallengeRuleContainer(dependency: self)
    let modifyChallengeHashtagContainable = ChallengeHashtagContainer(dependency: self)
    
    let coordinator = ChallengeModifyCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      viewPresentationModel: viewPresentationMdoel,
      modifyNameContainer: modifyChallengeNameContainable,
      modifyGoalContainer: modifyChallengeGoalContainable,
      modifyCoverContainer: modifyChallengeCoverContainable,
      modifyHashtagContainer: modifyChallengeHashtagContainable,
      modifyRuleContainer: modifyChallengeRuleContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
