//
//  EnterChallengeGoalContainer.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

enum ChallengeGoalMode {
  case edit(goal: String)
  case add
}

protocol EnterChallengeGoalDependency: Dependency { }

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
    let viewModel = EnterChallengeGoalViewModel(challengeID: challengeID)
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
