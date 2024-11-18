//
//  ProofChallengeContainer.swift
//  Presentation
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol ProofChallengeDependency: Dependency {
}

protocol ProofChallengeContainable: Containable {
  func coordinator(listener: ProofChallengeListener) -> Coordinating
}

final class ProofChallengeContainer:
  Container<ProofChallengeDependency>,
  ProofChallengeContainable {
  public func coordinator(listener: ProofChallengeListener) -> Coordinating {
    let viewModel = ProofChallengeViewModel()
    
    let coordinator = ProofChallengeCoordinator(
      viewModel: viewModel
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
