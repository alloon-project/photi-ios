//
//  ChallengeContainer.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core

public protocol ChallengeDependency: Dependency { }

public final class ChallengeContainer:
  Container<ChallengeDependency>,
  ChallengeContainable,
  FeedDependency,
  DescriptionDependency,
  ParticipantDependency,
  EditChallengeGoalDependency {
  public func coordinator(listener: ChallengeListener, challengeId: Int) -> ViewableCoordinating {
    let viewModel = ChallengeViewModel(challengeId: challengeId)
    let viewControllerable = ChallengeViewController(viewModel: viewModel)
    
    let feedContainer = FeedContainer(dependency: self)
    let descriptionContainer = DescriptionContainer(dependency: self)
    let participantContainer = ParticipantContainer(dependency: self)
    let editChallengeGoalContainer = EditChallengeGoalContainer(dependency: self)
    
    let coordinator = ChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      feedContainer: feedContainer,
      descriptionContainer: descriptionContainer,
      participantContainer: participantContainer,
      editChallengeGoalContainer: editChallengeGoalContainer
    )
    coordinator.listener = listener
    return coordinator
  }
}
