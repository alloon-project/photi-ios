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
  func coordinator(listener: EndedChallengeListener) -> ViewableCoordinating
}

protocol EndedChallengeDependency: Dependency {
  var endedChallengeUseCase: EndedChallengeUseCase { get }
}

final class EndedChallengeContainer:
  Container<EndedChallengeDependency>,
  EndedChallengeContainable {  
  func coordinator(listener: EndedChallengeListener) -> ViewableCoordinating {
    let viewModel = EndedChallengeViewModel(useCase: dependency.endedChallengeUseCase)
    let viewControllerable = EndedChallengeViewController(viewModel: viewModel)
    
    let coordinator = EndedChallengeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
