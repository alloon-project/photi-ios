//
//  HashTagResultContainer.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import RxCocoa
import UseCase

protocol HashTagResultDependency {
  var searchUseCase: SearchUseCase { get }
}

protocol HashTagResultContainable: Containable {
  func coordinator(
    listener: HashTagResultListener,
    searchInput: Driver<String>
  ) -> ViewableCoordinating
}

final class HashTagResultContainer: Container<HashTagResultDependency>, HashTagResultContainable {
  func coordinator(
    listener: HashTagResultListener,
    searchInput: Driver<String>
  ) -> ViewableCoordinating {
    let viewModel = HashTagResultViewModel(
     useCase: dependency.searchUseCase,
      searchInput: searchInput
    )
    let viewControllerable = HashTagResultViewController(viewModel: viewModel)
    
    let coordinator = HashTagResultCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
