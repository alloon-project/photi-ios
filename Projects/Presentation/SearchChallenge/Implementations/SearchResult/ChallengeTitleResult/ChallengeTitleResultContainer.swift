//
//  ChallengeTitleResultContainer.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import RxCocoa
import UseCase

protocol ChallengeTitleResultDependency {
  var searchUseCase: SearchUseCase { get }
}

protocol ChallengeTitleResultContainable: Containable {
  func coordinator(
    listener: ChallengeTitleResultListener,
    searchInput: Driver<String>
  ) -> ViewableCoordinating
}

final class ChallengeTitleResultContainer: Container<ChallengeTitleResultDependency>, ChallengeTitleResultContainable {
  func coordinator(
    listener: ChallengeTitleResultListener,
    searchInput: Driver<String>
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
