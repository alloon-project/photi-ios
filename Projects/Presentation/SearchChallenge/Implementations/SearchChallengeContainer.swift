//
//  SearchChallengeContainer.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Challenge
import SearchChallenge

public protocol SearchChallengeDependency: Dependency {
  var challengeOrganizeContainable: ChallengeOrganizeContainable { get }
}

public final class SearchChallengeContainer:
  Container<SearchChallengeDependency>,
  SearchChallengeContainable {
  public func coordinator(listener: SearchChallengeListener) -> ViewableCoordinating {
    let viewModel = SearchChallengeViewModel()
    let viewControllerable = SearchChallengeViewController(viewModel: viewModel)
    
    let coordinator = SearchChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      challengeOrganizeContainable: dependency.challengeOrganizeContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
