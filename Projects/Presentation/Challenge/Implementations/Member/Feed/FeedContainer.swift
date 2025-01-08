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
  func coordinator(listener: FeedListener) -> Coordinating
}

final class FeedContainer:
  Container<FeedDependency>,
  FeedContainable,
  FeedCommentDependency {
  func coordinator(listener: FeedListener) -> Coordinating {
    let viewModel = FeedViewModel()
    let feedDetailContainer = FeedCommentContainer(dependency: self)
    
    let coordinator = FeedCoordinator(
      viewModel: viewModel,
      feedDetailContainer: feedDetailContainer
    )
    coordinator.listener = listener
    return coordinator
  }
}
