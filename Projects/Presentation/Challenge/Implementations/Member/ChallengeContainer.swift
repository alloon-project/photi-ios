//
//  ChallengeContainer.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core

public protocol ChallengeDependency: Dependency { }

public final class ChallengeContainer:
  Container<ChallengeDependency>,
  ChallengeContainable,
  FeedDependency {
  public func coordinator(listener: ChallengeListener, challengeId: Int) -> Coordinating {
    let feedContainer = FeedContainer(dependency: self)
    
    let viewModel = ChallengeViewModel(challengeId: challengeId)
    let viewController = ChallengeViewController(viewModel: viewModel)
    let coordinator = ChallengeCoordinator(
      viewController: viewController,
      viewModel: viewModel,
      feedContainer: feedContainer
    )
    coordinator.listener = listener
    return coordinator
  }
}
