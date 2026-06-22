//
//  ChallengeTitleResultContainer.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import Coordinator
import UseCase

protocol ChallengeTitleResultDependency {
  var searchUseCase: SearchUseCase { get }
}

protocol ChallengeTitleResultContainable: Containable {
  func coordinator(
    listener: ChallengeTitleResultListener,
    searchInput: AnyPublisher<String, Never>
  ) -> ViewableCoordinating
}

final class ChallengeTitleResultContainer: Container<ChallengeTitleResultDependency>, ChallengeTitleResultContainable {
  func coordinator(
    listener: ChallengeTitleResultListener,
    searchInput: AnyPublisher<String, Never>
  ) -> ViewableCoordinating {
    let viewModel = ChallengeTitleResultViewModel(
      useCase: dependency.searchUseCase,
      searchInput: searchInput
    )
    let viewControllerable = ChallengeTitleResultViewController(viewModel: viewModel)
    
    let coordinator = ChallengeTitleResultCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
