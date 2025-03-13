//
//  ParticipantContainer.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ParticipantDependency: Dependency {
  var challengeUseCase: ChallengeUseCase { get }
}

protocol ParticipantContainable: Containable {
  func coordinator(challengeId: Int, listener: ParticipantListener) -> ViewableCoordinating
}

final class ParticipantContainer: Container<ParticipantDependency>, ParticipantContainable {
  func coordinator(challengeId: Int, listener: ParticipantListener) -> ViewableCoordinating {
    let viewModel = ParticipantViewModel(challengeId: challengeId, useCase: dependency.challengeUseCase)
    let viewControllerable = ParticipantViewController(viewModel: viewModel)
    
    let coordinator = ParticipantCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
