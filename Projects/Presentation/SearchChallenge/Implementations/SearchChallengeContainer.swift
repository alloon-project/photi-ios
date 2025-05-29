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
import UseCase

public protocol SearchChallengeDependency: Dependency {
  var challengeOrganizeContainable: ChallengeOrganizeContainable { get }
  var searchUseCase: SearchUseCase { get }
  var challengeContainable: ChallengeContainable { get }
  var noneMemberChallengeContainable: NoneMemberChallengeContainable { get }
}

public final class SearchChallengeContainer:
  Container<SearchChallengeDependency>,
  SearchChallengeContainable,
  RecommendedChallengesDependency,
  RecentChallengesDependency,
  SearchResultDependency {
  var searchUseCase: SearchUseCase { dependency.searchUseCase }
  var challengeContainable: ChallengeContainable { dependency.challengeContainable }
  var noneMemberChallengeContainable: NoneMemberChallengeContainable { dependency.noneMemberChallengeContainable }
  
  public func coordinator(listener: SearchChallengeListener) -> ViewableCoordinating {
    let viewModel = SearchChallengeViewModel(useCase: searchUseCase)
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
      searchResultContainable: searchResult,
      challengeContainable: dependency.challengeContainable,
      noneMemberChallengeContainable: dependency.noneMemberChallengeContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
