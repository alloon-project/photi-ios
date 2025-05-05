//
//  ChallengeGoalContainer.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeGoalDependency: Dependency {
}

protocol ChallengeGoalContainable: Containable {
  func coordinator(listener: ChallengeGoalListener) -> ViewableCoordinating
}

final class ChallengeGoalContainer: Container<ChallengeGoalDependency>, ChallengeGoalContainable {
  func coordinator(listener: ChallengeGoalListener) -> ViewableCoordinating {
    let viewModel = ChallengeGoalViewModel()
    let viewControllerable = ChallengeGoalViewController(viewModel: viewModel)
    
    let coordinator = ChallengeGoalCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
