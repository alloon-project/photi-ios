//
//  EnterChallengeGoalContainer.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

enum ChallengeGoalMode {
  case edit(goal: String)
  case join
}

protocol EnterChallengeGoalDependency: Dependency {
  var challengeUseCase: ChallengeUseCase { get }
}

protocol EnterChallengeGoalContainable: Containable {
  func coordinator(
    mode: ChallengeGoalMode,
    challengeID: Int,
    challengeName: String,
    listener: EnterChallengeGoalListener
  ) -> ViewableCoordinating
}

final class EnterChallengeGoalContainer: Container<EnterChallengeGoalDependency>, EnterChallengeGoalContainable {
  func coordinator(
    mode: ChallengeGoalMode,
    challengeID: Int,
    challengeName: String,
    listener: EnterChallengeGoalListener
  ) -> ViewableCoordinating {
    let viewModel = EnterChallengeGoalViewModel(
      mode: mode,
      challengeID: challengeID,
      useCase: dependency.challengeUseCase
    )
    let viewControllerable = EnterChallengeGoalViewController(
      mode: mode,
      challengeName: challengeName,
      viewModel: viewModel
    )
    
    let coordinator = EnterChallengeGoalCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
