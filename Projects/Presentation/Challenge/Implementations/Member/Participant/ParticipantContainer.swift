//
//  ParticipantContainer.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import UseCase

protocol ParticipantDependency {
  var challengeUseCase: ChallengeUseCase { get }
}

protocol ParticipantContainable: Containable {
  func coordinator(
    challengeId: Int,
    challengeName: String,
    listener: ParticipantListener
  ) -> ViewableCoordinating
}

final class ParticipantContainer:
  Container<ParticipantDependency>,
  ParticipantContainable,
  EnterChallengeGoalDependency {
  var challengeUseCase: ChallengeUseCase { dependency.challengeUseCase }

  func coordinator(
    challengeId: Int,
    challengeName: String,
    listener: ParticipantListener
  ) -> ViewableCoordinating {
    let viewModel = ParticipantViewModel(
      challengeId: challengeId,
      challegeName: challengeName,
      useCase: dependency.challengeUseCase
    )
    let viewControllerable = ParticipantViewController(viewModel: viewModel)
    
    let editChallengeGoalContainer = EnterChallengeGoalContainer(dependency: self)

    let coordinator = ParticipantCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      editChallengeGoalContainer: editChallengeGoalContainer
    )
    coordinator.listener = listener
    return coordinator
  }
}
