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

final class SearchResultContainer: Container<SearchResultDependency>, SearchResultContainable {
  func coordinator(listener: SearchResultListener) -> ViewableCoordinating {
    let viewModel = SearchResultViewModel()
    let viewControllerable = SearchResultViewController(viewModel: viewModel)
    
    let coordinator = SearchResultCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
