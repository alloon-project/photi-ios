//
//  ChallengeHomeContainer.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ChallengeHomeDependency: Dependency {
  var homeUseCase: HomeUseCase { get }
}

protocol ChallengeHomeContainable: Containable {
  func coordinator(listener: ChallengeHomeListener) -> ViewableCoordinating
}

final class ChallengeHomeContainer: Container<ChallengeHomeDependency>, ChallengeHomeContainable {
  func coordinator(listener: ChallengeHomeListener) -> ViewableCoordinating {
    let viewModel = ChallengeHomeViewModel(useCase: dependency.homeUseCase)
    let viewControllerable = ChallengeHomeViewController(viewModel: viewModel)
    
    let coordinator = ChallengeHomeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
