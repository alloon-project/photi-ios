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
  func coordinator(
    mode: ChallengeOrganizeMode,
    listener: ChallengeNameListener
  ) -> ViewableCoordinating
}

final class ChallengeNameContainer: Container<ChallengeNameDependency>, ChallengeNameContainable {
  func coordinator(
    mode: ChallengeOrganizeMode,
    listener: ChallengeNameListener
  ) -> ViewableCoordinating {
    let viewModel = ChallengeNameViewModel(
      mode: mode,
      useCase: dependency.organizeUseCase
    )
    let viewControllerable = ChallengeNameViewController(
      mode: mode,
      viewModel: viewModel
    )
    
    let coordinator = ChallengeNameCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
