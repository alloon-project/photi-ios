//
//  FeedDetailContainer.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol FeedCommentDependency: Dependency {
  var feedUseCase: FeedUseCase { get }
}

protocol FeedCommentContainable: Containable {
  func coordinator(
    listener: FeedCommentListener,
    challengeId: Int,
    feedId: Int
  ) -> ViewableCoordinating
}

final class FeedCommentContainer: Container<FeedCommentDependency>, FeedCommentContainable {
  func coordinator(
    listener: FeedCommentListener,
    challengeId: Int,
    feedId: Int
  ) -> ViewableCoordinating {
    let viewModel = FeedCommentViewModel(
      useCase: dependency.feedUseCase,
      challengeId: challengeId,
      feedID: feedId
    )
    let viewControllerable = FeedCommentViewController(viewModel: viewModel)
    
    let coordinator = FeedCommentCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
