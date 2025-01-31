//
//  NoneMemberChallengeContainer.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Challenge
import Core
import UseCase

public protocol NoneMemberChallengeDependency: Dependency {
  var challengeUseCase: ChallengeUseCase { get }
}

public final class NoneMemberChallengeContainer:
  Container<NoneMemberChallengeDependency>,
  NoneMemberChallengeContainable,
  EnterChallengeGoalDependency {
  public func coordinator(listener: NoneMemberChallengeListener, challengeId: Int) -> ViewableCoordinating {
    let viewModel = NoneMemberChallengeViewModel(challengeId: challengeId, useCase: dependency.challengeUseCase)
    let viewControllerable = NoneMemberChallengeViewController(viewModel: viewModel)
    
    let enterChallengeGoalContainer = EnterChallengeGoalContainer(dependency: self)
    
    let coordinator = NoneMemberChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      enterChallengeGoalContainer: enterChallengeGoalContainer
    )
    coordinator.listener = listener
    return coordinator
  }
}
