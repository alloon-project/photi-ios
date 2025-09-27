//
//  ChallengeOrganizeContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import Challenge
import UseCase

public protocol ChallengeOrganizeDependency {
  var organizeUseCase: OrganizeUseCase { get }
}

public final class ChallengeOrganizeContainer:
  Container<ChallengeOrganizeDependency>,
    ChallengeOrganizeContainable,
    ChallengeStartDependency,
    ChallengeNameDependency,
    ChallengeGoalDependency,
    ChallengeCoverDependency,
    ChallengeRuleDependency,
    ChallengeHashtagDependency,
    ChallengePreviewDependency {
  var organizeUseCase: OrganizeUseCase {
    dependency.organizeUseCase
  }
  
  public func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: ChallengeOrganizeListener
  ) -> Coordinator {
    let challengeStartContainable = ChallengeStartContainer(dependency: self)
    let challengeNameContainable = ChallengeNameContainer(dependency: self)
    let challengeGoalContainable = ChallengeGoalContainer(dependency: self)
    let challengeCoverContainable = ChallengeCoverContainer(dependency: self)
    let challengeRuleContainable = ChallengeRuleContainer(dependency: self)
    let challengeHashtagContainable = ChallengeHashtagContainer(dependency: self)
    let challengePreviewContainable = ChallengePreviewContainer(dependency: self)
    
    let coordinator = ChallengeOrganizeCoordinator(
      navigationControllerable: navigationControllerable,
      challengeStartContainable: challengeStartContainable,
      challengeNameContainable: challengeNameContainable,
      challengeGoalContainable: challengeGoalContainable,
      challengeCoverContainable: challengeCoverContainable,
      challengeRuleContainable: challengeRuleContainable,
      challengeHashtagContainable: challengeHashtagContainable,
      challengePreviewContainable: challengePreviewContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
