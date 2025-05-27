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
  SearchChallengeContainable,
  RecommendedChallengesDependency,
  RecentChallengesDependency,
  SearchResultDependency {
  public func coordinator(listener: SearchChallengeListener) -> ViewableCoordinating {
    let viewModel = SearchChallengeViewModel()
    let viewControllerable = SearchChallengeViewController(viewModel: viewModel)
    
    let recommendedChallenges = RecommendedChallengesContainer(dependency: self)
    let recentChallenges = RecentChallengesContainer(dependency: self)
    let searchResult = SearchResultContainer(dependency: self)
    
    let coordinator = SearchChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      challengeOrganizeContainable: dependency.challengeOrganizeContainable,
      recommendedChallengesContainable: recommendedChallenges,
      recentChallengesContainable: recentChallenges,
      searchResultContainable: searchResult
    )
    coordinator.listener = listener
    return coordinator
  }
}
