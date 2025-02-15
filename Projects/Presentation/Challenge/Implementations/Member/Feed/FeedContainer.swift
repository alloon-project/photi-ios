//
//  FeedContainer.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol FeedDependency: Dependency { }

protocol FeedContainable: Containable {
  func coordinator(listener: FeedListener) -> ViewableCoordinating
}

final class FeedContainer:
  Container<FeedDependency>,
  FeedContainable,
  FeedCommentDependency {
  func coordinator(listener: FeedListener) -> ViewableCoordinating {
    let viewModel = FeedViewModel()
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
