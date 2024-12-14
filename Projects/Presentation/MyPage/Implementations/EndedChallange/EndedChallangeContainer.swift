//
//  EndedChallengeContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol EndedChallengeContainable: Containable {
  func coordinator(listener: EndedChallengeListener) -> Coordinating
}

protocol EndedChallengeDependency: Dependency {
  var endedChallengeUseCase: EndedChallengeUseCase { get }
}

final class EndedChallengeContainer:
  Container<EndedChallengeDependency>,
  EndedChallengeContainable {
  public func coordinator(listener: EndedChallengeListener) -> Coordinating {
    let viewModel = EndedChallengeViewModel(useCase: dependency.endedChallengeUseCase)
    
    let coordinator = EndedChallengeCoordinator(
      viewModel: viewModel
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
