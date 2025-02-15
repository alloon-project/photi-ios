//
//  ChallengeHomeContainer.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeHomeDependency: Dependency { }

protocol ChallengeHomeContainable: Containable {
  func coordinator(listener: ChallengeHomeListener) -> ViewableCoordinating
}

final class ChallengeHomeContainer: Container<ChallengeHomeDependency>, ChallengeHomeContainable {
  func coordinator(listener: ChallengeHomeListener) -> ViewableCoordinating {
    let viewModel = ChallengeHomeViewModel()
    let viewControllerable = ChallengeHomeViewController(viewModel: viewModel)
    
    let coordinator = ChallengeHomeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
