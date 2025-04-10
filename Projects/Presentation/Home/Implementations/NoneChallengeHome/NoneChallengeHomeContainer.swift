//
//  NoneChallengeHomeContainer.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core
import UseCase

protocol NoneChallengeHomeDependency: Dependency {
  var homeUseCase: HomeUseCase { get }
  var noneMemberChallengeContainable: NoneMemberChallengeContainable { get }
}

protocol NoneChallengeHomeContainable: Containable {
  func coordinator(listener: NoneChallengeHomeListener) -> ViewableCoordinating
}

final class NoneChallengeHomeContainer:
  Container<NoneChallengeHomeDependency>,
  NoneChallengeHomeContainable {
  func coordinator(listener: NoneChallengeHomeListener) -> ViewableCoordinating {
    let viewModel = NoneChallengeHomeViewModel(useCase: dependency.homeUseCase)
    let viewControllerable = NoneChallengeHomeViewController(viewModel: viewModel)
    
    let coordinator = NoneChallengeHomeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      noneMemberChallengeContainer: dependency.noneMemberChallengeContainable
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
