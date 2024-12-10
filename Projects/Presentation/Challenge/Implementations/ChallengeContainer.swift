//
//  ChallengeContainer.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core

public protocol ChallengeDependency: Dependency { }

public final class ChallengeContainer:
  Container<ChallengeDependency>,
  ChallengeContainable {
  public func coordinator(listener: ChallengeListener, challengeId: Int) -> Coordinating {
    let viewModel = ChallengeViewModel(challengeId: challengeId)
    let coordinator = ChallengeCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
