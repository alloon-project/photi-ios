//
//  RecentChallengesContainer.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol RecentChallengesDependency: Dependency { }

protocol RecentChallengesContainable: Containable {
  func coordinator(listener: RecentChallengesListener) -> ViewableCoordinating
}

final class RecentChallengesContainer: Container<RecentChallengesDependency>, RecentChallengesContainable {
  func coordinator(listener: RecentChallengesListener) -> ViewableCoordinating {
    let viewModel = RecentChallengesViewModel()
    let viewControllerable = RecentChallengesViewController(viewModel: viewModel)
    
    let coordinator = RecentChallengesCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
