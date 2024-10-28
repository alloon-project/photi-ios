//
//  FinishedChallengeContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol FinishedChallengeDependency: Dependency {
}

protocol FinishedChallengeContainable: Containable {
  func coordinator(listener: FinishedChallengeListener) -> Coordinating
}

final class FinishedChallengeContainer:
  Container<FinishedChallengeDependency>,
  FinishedChallengeContainable {  
  public func coordinator(listener: FinishedChallengeListener) -> Coordinating {
    let viewModel = FinishedChallengeViewModel()
    
    let coordinator = FinishedChallengeCoordinator(
      viewModel: viewModel
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
