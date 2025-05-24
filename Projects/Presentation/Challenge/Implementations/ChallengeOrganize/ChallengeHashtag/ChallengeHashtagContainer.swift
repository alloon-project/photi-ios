//
//  ChallengeHashtagContainer.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ChallengeHashtagDependency: Dependency {
  var organizeUseCase: OrganizeUseCase { get }
}

protocol ChallengeHashtagContainable: Containable {
  func coordinator(listener: ChallengeHashtagListener) -> ViewableCoordinating
}

final class ChallengeHashtagContainer: Container<ChallengeHashtagDependency>, ChallengeHashtagContainable {
  func coordinator(listener: ChallengeHashtagListener) -> ViewableCoordinating {
    let viewModel = ChallengeHashtagViewModel(useCase: dependency.organizeUseCase)
    let viewControllerable = ChallengeHashtagViewController(viewModel: viewModel)
    
    let coordinator = ChallengeHashtagCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
