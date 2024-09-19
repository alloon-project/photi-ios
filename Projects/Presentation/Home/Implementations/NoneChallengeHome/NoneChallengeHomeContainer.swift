//
//  NoneChallengeHomeContainer.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol NoneChallengeHomeDependency: Dependency { }

protocol NoneChallengeHomeContainable: Containable {
  func coordinator(listener: NoneChallengeHomeListener) -> Coordinating
}

final class NoneChallengeHomeContainer:
  Container<NoneChallengeHomeDependency>,
  NoneChallengeHomeContainable {
  func coordinator(listener: NoneChallengeHomeListener) -> Coordinating {
    let viewModel = NoneChallengeHomeViewModel()
    let coordinator = NoneChallengeHomeCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    
    return coordinator
  }
}
