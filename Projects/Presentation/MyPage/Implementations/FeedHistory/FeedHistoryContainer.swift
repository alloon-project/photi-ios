//
//  FeedHistoryContainer.swift
//  Presentation
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol FeedHistoryDependency: Dependency {
  var feedHistoryUseCase: FeedUseCase { get }
}

protocol FeedHistoryContainable: Containable {
  func coordinator(listener: FeedHistoryListener, feedCount: Int) -> ViewableCoordinating
}

final class FeedHistoryContainer:
  Container<FeedHistoryDependency>,
  FeedHistoryContainable {
  func coordinator(listener: FeedHistoryListener, feedCount: Int) -> ViewableCoordinating {
    let viewModel = FeedHistoryViewModel(useCase: dependency.feedHistoryUseCase)
    let viewControllerable = FeedHistoryViewController(viewModel: viewModel)
    
    let coordinator = FeedHistoryCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      feedCount: feedCount
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
