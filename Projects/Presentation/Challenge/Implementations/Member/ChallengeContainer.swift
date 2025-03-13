//
//  ChallengeContainer.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core
import UseCase

public protocol ChallengeDependency: Dependency {
  var challengeUseCase: ChallengeUseCase { get }
  var feedUseCase: FeedUseCase { get }
}

public final class ChallengeContainer:
  Container<ChallengeDependency>,
  ChallengeContainable,
  FeedDependency,
  DescriptionDependency,
  ParticipantDependency {
  public func coordinator(listener: ChallengeListener, challengeId: Int) -> ViewableCoordinating {
    let viewModel = ChallengeViewModel(useCase: dependency.challengeUseCase, challengeId: challengeId)
    let viewControllerable = ChallengeViewController(viewModel: viewModel)
    
    let feedContainer = FeedContainer(dependency: self)
    let descriptionContainer = DescriptionContainer(dependency: self)
    let participantContainer = ParticipantContainer(dependency: self)
    
    let coordinator = ChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      feedContainer: feedContainer,
      descriptionContainer: descriptionContainer,
      participantContainer: participantContainer
    )
    coordinator.listener = listener
    return coordinator
  }
  
  var challengeUseCase: ChallengeUseCase { dependency.challengeUseCase }
  var feedUseCase: FeedUseCase { dependency.feedUseCase }
}
