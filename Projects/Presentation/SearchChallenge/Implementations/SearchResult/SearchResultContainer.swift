//
//  SearchResultContainer.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol SearchResultDependency: Dependency {
  var searchUseCase: SearchUseCase { get }
}

protocol SearchResultContainable: Containable {
  func coordinator(listener: SearchResultListener) -> ViewableCoordinating
}

final class SearchResultContainer:
  Container<SearchResultDependency>,
  SearchResultContainable,
  ChallengeTitleResultDependency,
  HashTagResultDependency {
  var searchUseCase: SearchUseCase { dependency.searchUseCase }
  
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
