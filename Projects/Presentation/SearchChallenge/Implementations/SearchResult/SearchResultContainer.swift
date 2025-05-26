//
//  SearchResultContainer.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol SearchResultDependency: Dependency { }

protocol SearchResultContainable: Containable {
  func coordinator(listener: SearchResultListener) -> ViewableCoordinating
}

final class SearchResultContainer:
  Container<SearchResultDependency>,
  SearchResultContainable,
  ChallengeTitleResultDependency,
  HashTagResultDependency {
  func coordinator(listener: SearchResultListener) -> ViewableCoordinating {
    let viewModel = SearchResultViewModel()
    let viewControllerable = SearchResultViewController(viewModel: viewModel)
    
    let challengeTitleResult = ChallengeTitleResultContainer(dependency: self)
    let hashTagResult = HashTagResultContainer(dependency: self)
    
    let coordinator = SearchResultCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      challengeTitleReulstContainable: challengeTitleResult,
      hashTagResultContainable: hashTagResult
    )
    coordinator.listener = listener
    return coordinator
  }
}
