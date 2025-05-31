//
//  ModifyChallengeNameContainer.swift
//  Presentation
//
//  Created by 임우섭 on 5/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ModifyChallengeNameDependency: Dependency { }

protocol ModifyChallengeNameContainable: Containable {
  func coordinator(listener: ModifyChallengeNameListener) -> ViewableCoordinating
}

final class ModifyChallengeNameContainer: Container<ModifyChallengeNameDependency>, ModifyChallengeNameContainable {
  func coordinator(listener: ChallengeNameListener) -> ViewableCoordinating {
    let viewModel = ModifyChallengeNameViewModel()
    let viewControllerable = ModifyChallengeNameViewController(viewModel: viewModel)
    
    let coordinator = ModifyChallengeNameCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
