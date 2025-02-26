//
//  FeedContainer.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol FeedDependency: Dependency {
  var challengeUseCase: ChallengeUseCase { get }
}

protocol FeedContainable: Containable {
  func coordinator(challengeId: Int, listener: FeedListener) -> ViewableCoordinating
}

final class FeedContainer:
  Container<FeedDependency>,
  FeedContainable,
  FeedCommentDependency {
  func coordinator(challengeId: Int, listener: FeedListener) -> ViewableCoordinating {
    let viewModel = FeedViewModel(challengeId: challengeId, useCase: dependency.challengeUseCase)
    let viewControllerable = FeedViewController(viewModel: viewModel)
    
    let feedCommentContainer = FeedCommentContainer(dependency: self)
    
    let coordinator = FeedCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      feedCommentContainer: feedCommentContainer
    )
    coordinator.listener = listener
    return coordinator
  }
}
