//
//  FeedDetailContainer.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator
import UseCase

protocol FeedCommentDependency {
  var feedUseCase: FeedUseCase { get }
}

protocol FeedCommentContainable: Containable {
  func coordinator(
    listener: FeedCommentListener,
    challengeName: String,
    challengeId: Int,
    feedId: Int
  ) -> ViewableCoordinating
}

final class FeedCommentContainer: Container<FeedCommentDependency>, FeedCommentContainable {
  func coordinator(
    listener: FeedCommentListener,
    challengeName: String,
    challengeId: Int,
    feedId: Int
  ) -> ViewableCoordinating {
    let viewModel = FeedCommentViewModel(
      useCase: dependency.feedUseCase,
      challengeName: challengeName,
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
