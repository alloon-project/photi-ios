//
//  ChallengeNameContainer.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ChallengeNameDependency: Dependency {
  var organizeUseCase: OrganizeUseCase { get }
}

protocol ChallengeNameContainable: Containable {
  func coordinator(listener: ChallengeNameListener) -> ViewableCoordinating
}

final class ChallengeNameContainer: Container<ChallengeNameDependency>, ChallengeNameContainable {
  func coordinator(listener: ChallengeNameListener) -> ViewableCoordinating {
    let viewModel = ChallengeNameViewModel(useCase: dependency.organizeUseCase)
    let viewControllerable = ChallengeNameViewController(viewModel: viewModel)
    
    let coordinator = ChallengeNameCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
