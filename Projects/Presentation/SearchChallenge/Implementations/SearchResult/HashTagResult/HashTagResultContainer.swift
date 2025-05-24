//
//  HashTagResultContainer.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol HashTagResultDependency: Dependency { }

protocol HashTagResultContainable: Containable {
  func coordinator(listener: HashTagResultListener) -> ViewableCoordinating
}

final class HashTagResultContainer: Container<HashTagResultDependency>, HashTagResultContainable {
  func coordinator(listener: HashTagResultListener) -> ViewableCoordinating {
    let viewModel = HashTagResultViewModel()
    let viewControllerable = HashTagResultViewController(viewModel: viewModel)
    
    let coordinator = HashTagResultCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
