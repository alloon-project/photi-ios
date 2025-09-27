//
//  FeedHistoryContainer.swift
//  Presentation
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator
import Challenge
import UseCase

protocol FeedHistoryDependency {
  var myPageUseCase: MyPageUseCase { get }
  var challengeContainable: ChallengeContainable { get }
}

protocol FeedHistoryContainable: Containable {
  func coordinator(listener: FeedHistoryListener, feedCount: Int) -> ViewableCoordinating
}

final class FeedHistoryContainer:
  Container<FeedHistoryDependency>,
  FeedHistoryContainable {
  func coordinator(listener: FeedHistoryListener, feedCount: Int) -> ViewableCoordinating {
    let viewModel = FeedHistoryViewModel(useCase: dependency.myPageUseCase)
    let viewControllerable = FeedHistoryViewController(viewModel: viewModel)
    
    let coordinator = FeedHistoryCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      feedCount: feedCount,
      challengeContainable: dependency.challengeContainable
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
