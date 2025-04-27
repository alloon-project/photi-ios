//
//  ChallengeCoverContainer.swift
//  Presentation
//
//  Created by 임우섭 on 3/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ChallengeCoverDependency: Dependency {
  var challengeUseCase: ChallengeUseCase { get }
}

protocol ChallengeCoverContainable: Containable {
  func coordinator(listener: ChallengeCoverListener) -> ViewableCoordinating
}

final class ChallengeCoverContainer: Container<ChallengeCoverDependency>, ChallengeCoverContainable {
  func coordinator(listener: ChallengeCoverListener) -> ViewableCoordinating {
    let viewModel = ChallengeCoverViewModel(useCase: dependency.challengeUseCase)
    let viewControllerable = ChallengeCoverViewController(viewModel: viewModel)
    
    let coordinator = ChallengeCoverCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
