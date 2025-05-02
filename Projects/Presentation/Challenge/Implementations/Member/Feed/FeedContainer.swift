//
//  FeedContainer.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core
import UseCase

protocol FeedDependency: Dependency {
  var challengeUseCase: ChallengeUseCase { get }
  var feedUseCase: FeedUseCase { get }
}

protocol FeedContainable: Containable {
  func coordinator(
    challengeId: Int,
    listener: FeedListener,
    presentType: ChallengePresentType
  ) -> ViewableCoordinating
}

final class FeedContainer:
  Container<FeedDependency>,
  FeedContainable,
  FeedCommentDependency {
  var feedUseCase: FeedUseCase { dependency.feedUseCase }

  func coordinator(
    challengeId: Int,
    listener: FeedListener,
    presentType: ChallengePresentType
  ) -> ViewableCoordinating {
    let viewModel = FeedViewModel(challengeId: challengeId, useCase: dependency.challengeUseCase)
    let viewControllerable = FeedViewController(viewModel: viewModel)
    
    let feedCommentContainer = FeedCommentContainer(dependency: self)
    
    let coordinator = FeedCoordinator(
      challengeId: challengeId,
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      initialPresentType: presentType,
      feedCommentContainer: feedCommentContainer
    )
    coordinator.listener = listener
    return coordinator
  }
}
