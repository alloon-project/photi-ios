//
//  EditChallengeGoalContainer.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol EditChallengeGoalDependency: Dependency { }

protocol EditChallengeGoalContainable: Containable {
  func coordinator(
    userID: Int,
    challengeID: Int,
    listener: EditChallengeGoalListener
  ) -> ViewableCoordinating
}

final class EditChallengeGoalContainer: Container<EditChallengeGoalDependency>, EditChallengeGoalContainable {
  func coordinator(
    userID: Int,
    challengeID: Int,
    listener: EditChallengeGoalListener
  ) -> ViewableCoordinating {
    let viewModel = EditChallengeGoalViewModel()
    let viewControllerable = EditChallengeGoalViewController(viewModel: viewModel)
    
    let coordinator = EditChallengeGoalCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
