//
//  ChallengeOrganizeContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeOrganizeDependency: Dependency { }

protocol ChallengeOrganizeContainable: Containable {
  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: ChallengeOrganizeListener
  ) -> ViewableCoordinating
}

final class ChallengeOrganizeContainer:
  Container<ChallengeOrganizeDependency>,
    ChallengeOrganizeContainable,
    ChallengeStartDependency,
    ChallengeNameDependency,
    ChallengeGoalDependency,
    ChallengeCoverDependency,
    ChallengeRuleDependency,
    ChallengeHashTagDependency,
    ChallengePreviewDependency
{
  
  
  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: ChallengeOrganizeListener
  ) -> ViewableCoordinating {
    let challengeStartContainable = ChallengeStartContainer(dependency: self)
    let challengeNameContainable = ChallengeNameContainer(dependency: self)
    let challengeGoalContainable = ChallengeGoalContainer(dependency: self)
    let challengeCoverContainable = ChallengeCoverContainer(dependency: self)
    let challengeRuleContainable = ChallengeRuleContainer(dependency: self)
    let challengeHashTagContainable = ChallengeHashTagContainer(dependency: self)
    let challengePreviewContainable = ChallengePreviewContainer(dependency: self)
    
    
    let coordinator = ChallengeOrganizeCoordinator(
      navigationControllerable: navigationControllerable,
      challengeStartContainable: challengeStartContainable,
      challengeNameContainable: challengeNameContainable,
      challengeGoalContainable: challengeGoalContainable,
      challengeCoverContainable: challengeCoverContainable,
      challengeRuleContainable: challengeRuleContainable,
      challengeHashTagContainable: challengeHashTagContainable,
      challengePreviewContainable: challengePreviewContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}

