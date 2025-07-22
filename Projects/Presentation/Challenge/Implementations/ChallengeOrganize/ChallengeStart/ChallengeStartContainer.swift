//
//  ChallengeStartContainer.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeStartDependency: Dependency {
}

protocol ChallengeStartContainable: Containable {
  func coordinator(listener: ChallengeStartListener) -> ViewableCoordinating
}

final class ChallengeStartContainer:
  Container<ChallengeStartDependency>,
  ChallengeStartContainable {
  func coordinator(listener: ChallengeStartListener) -> ViewableCoordinating {
    let viewModel = ChallengeStartViewModel()
    let viewControllerable = ChallengeStartViewController(viewModel: viewModel)
    
    let coordinator = ChallengeStartCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
