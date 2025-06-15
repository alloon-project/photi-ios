//
//  ChallengeGoalContainer.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ChallengeGoalDependency: Dependency {
  var organizeUseCase: OrganizeUseCase { get }
}

protocol ChallengeGoalContainable: Containable {
  func coordinator(
    mode: ChallengeOrganizeMode,
    goal: String?,
    proveTime: String?,
    endDate: String?,
    listener: ChallengeGoalListener
  ) -> ViewableCoordinating
}

final class ChallengeGoalContainer: Container<ChallengeGoalDependency>, ChallengeGoalContainable {
  func coordinator(
    mode: ChallengeOrganizeMode,
    goal: String?,
    proveTime: String?,
    endDate: String?,
    listener: ChallengeGoalListener
  ) -> ViewableCoordinating {
    let viewModel = ChallengeGoalViewModel(
      mode: mode,
      useCase: dependency.organizeUseCase
    )
    let viewControllerable = ChallengeGoalViewController(
      mode: mode,
      viewModel: viewModel
    )
    
    let coordinator = ChallengeGoalCoordinator(
      viewControllerable: viewControllerable,
      goal: goal,
      proveTime: proveTime,
      endDate: endDate,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
