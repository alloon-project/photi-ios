//
//  ParticipantContainer.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ParticipantDependency: Dependency { }

protocol ParticipantContainable: Containable {
  func coordinator(listener: ParticipantListener) -> ViewableCoordinating
}

final class ParticipantContainer: Container<ParticipantDependency>, ParticipantContainable {
  func coordinator(listener: ParticipantListener) -> ViewableCoordinating {
    let viewModel = ParticipantViewModel()
    let viewControllerable = ParticipantViewController(viewModel: viewModel)
    
    let coordinator = ParticipantCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
