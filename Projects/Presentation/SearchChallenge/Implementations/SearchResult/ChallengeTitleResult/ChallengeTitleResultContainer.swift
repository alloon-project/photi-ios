//
//  ChallengeTitleResultContainer.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeTitleResultDependency: Dependency { }

protocol ChallengeTitleResultContainable: Containable {
  func coordinator(listener: ChallengeTitleResultListener) -> ViewableCoordinating
}

final class ChallengeTitleResultContainer: Container<ChallengeTitleResultDependency>, ChallengeTitleResultContainable {
  func coordinator(listener: ChallengeTitleResultListener) -> ViewableCoordinating {
    let viewModel = ChallengeTitleResultViewModel()
    let viewControllerable = ChallengeTitleResultViewController(viewModel: viewModel)
    
    let coordinator = ChallengeTitleResultCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
