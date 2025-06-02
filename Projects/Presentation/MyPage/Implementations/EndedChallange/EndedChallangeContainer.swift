//
//  EndedChallengeContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol EndedChallengeDependency: Dependency {
  var myPageUseCase: MyPageUseCase { get }
}

protocol EndedChallengeContainable: Containable {
  func coordinator(endedChallengeCount: Int, listener: EndedChallengeListener) -> ViewableCoordinating
}

final class EndedChallengeContainer:
  Container<EndedChallengeDependency>,
  EndedChallengeContainable {  
  func coordinator(endedChallengeCount: Int, listener: EndedChallengeListener) -> ViewableCoordinating {
    let viewModel = EndedChallengeViewModel(useCase: dependency.myPageUseCase)
    let viewControllerable = EndedChallengeViewController(viewModel: viewModel)
    
    let coordinator = EndedChallengeCoordinator(
      endedChallengeCount: endedChallengeCount,
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
