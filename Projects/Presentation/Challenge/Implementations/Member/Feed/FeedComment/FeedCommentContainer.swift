//
//  FeedDetailContainer.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol FeedCommentDependency: Dependency { }

protocol FeedCommentContainable: Containable {
  func coordinator(listener: FeedCommentListener, feedID: String) -> ViewableCoordinating
}

final class FeedCommentContainer: Container<FeedCommentDependency>, FeedCommentContainable {
  func coordinator(listener: FeedCommentListener, feedID: String) -> ViewableCoordinating {
    let viewModel = FeedCommentViewModel(feedID: feedID)
    let viewControllerable = FeedCommentViewController(viewModel: viewModel)
    
    let coordinator = FeedCommentCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
