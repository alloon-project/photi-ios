//
//  DescriptionContainer.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import UseCase

protocol DescriptionDependency {
  var challengeUseCase: ChallengeUseCase { get }
}

protocol DescriptionContainable: Containable {
  func coordinator(challengeId: Int, listener: DescriptionListener) -> ViewableCoordinating
}

final class DescriptionContainer: Container<DescriptionDependency>, DescriptionContainable {
  func coordinator(challengeId: Int, listener: DescriptionListener) -> ViewableCoordinating {
    let viewModel = DescriptionViewModel(challengeId: challengeId, useCase: dependency.challengeUseCase)
    let viewControllerable = DescriptionViewController(viewModel: viewModel)
    
    let coordinator = DescriptionCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
