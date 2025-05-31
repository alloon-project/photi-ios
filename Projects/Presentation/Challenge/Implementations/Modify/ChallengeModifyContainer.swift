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

public protocol ChallengeModifyDependency: Dependency {
  var organizeUseCase: OrganizeUseCase { get }
}

public final class ChallengeModifyContainer:
  Container<ChallengeModifyDependency>,
  ModifyChallengeNameDependency,
  ChallengeGoalDependency,
  ChallengeCoverDependency,
  ChallengeRuleDependency,
  ChallengeHashtagDependency {
  var organizeUseCase: OrganizeUseCase { dependency.organizeUseCase }

  public func coordinator(
    listener: ModifyChallengeListener
  ) -> ViewableCoordinating {
    let viewModel = ChallengeModifyViewModel(useCase: dependency.organizeUseCase)
    let viewControllerable = ChallengeModifyViewController(viewModel: viewModel)
    
    let modifyChallengeNameContainable = ModifyChallengeNameContainer(dependency: self)
    let modifyChallengeGoalContainable = ChallengeGoalContainer(dependency: self)
    let modifyChallengeCoverContainable = ChallengeCoverContainer(dependency: self)
    let modifyChallengeRuleContainable = ChallengeRuleContainer(dependency: self)
    let modifyChallengeHashtagContainable = ChallengeHashtagContainer(dependency: self)
    
    let coordinator = ChallengeModifyCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
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
