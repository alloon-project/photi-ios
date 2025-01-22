//
//  NoneMemberChallengeContainer.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol NoneMemberChallengeDependency: Dependency { }

protocol NoneMemberChallengeContainable: Containable {
  func coordinator(listener: NoneMemberChallengeListener) -> ViewableCoordinating
}

final class NoneMemberChallengeContainer: Container<NoneMemberChallengeDependency>, NoneMemberChallengeContainable {
  func coordinator(listener: NoneMemberChallengeListener) -> ViewableCoordinating {
    let viewModel = NoneMemberChallengeViewModel()
    let viewControllerable = NoneMemberChallengeViewController(viewModel: viewModel)
    
    let coordinator = NoneMemberChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
