//
//  RecommendedChallengesContainer.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import UseCase

protocol RecommendedChallengesDependency {
  var searchUseCase: SearchUseCase { get }
}

protocol RecommendedChallengesContainable: Containable {
  func coordinator(listener: RecommendedChallengesListener) -> ViewableCoordinating
}

final class RecommendedChallengesContainer:
  Container<RecommendedChallengesDependency>,
  RecommendedChallengesContainable {
  func coordinator(listener: RecommendedChallengesListener) -> ViewableCoordinating {
    let viewModel = RecommendedChallengesViewModel(useCase: dependency.searchUseCase)
    let viewControllerable = RecommendedChallengesViewController(viewModel: viewModel)
    
    let coordinator = RecommendedChallengesCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
