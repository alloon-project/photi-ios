//
//  ProofChallengeContainer.swift
//  Presentation
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol ProofChallengeDependency: Dependency { }

protocol ProofChallengeContainable: Containable {
  func coordinator(listener: ProofChallengeListener) -> ViewableCoordinating
}

final class ProofChallengeContainer:
  Container<ProofChallengeDependency>,
  ProofChallengeContainable {
  func coordinator(listener: ProofChallengeListener) -> ViewableCoordinating {
    let viewModel = ProofChallengeViewModel()
    let viewControllerable = ProofChallengeViewController(viewModel: viewModel)
    
    let coordinator = ProofChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
