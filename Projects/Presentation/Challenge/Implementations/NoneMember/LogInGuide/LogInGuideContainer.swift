//
//  LogInGuideContainer.swift
//  ChallengeImpl
//
//  Created by jung on 1/31/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol LogInGuideDependency: Dependency { }

protocol LogInGuideContainable: Containable {
  func coordinator(listener: LogInGuideListener) -> ViewableCoordinating
}

final class LogInGuideContainer: Container<LogInGuideDependency>, LogInGuideContainable {
  func coordinator(listener: LogInGuideListener) -> ViewableCoordinating {
    let viewModel = LogInGuideViewModel()
    let viewControllerable = LogInGuideViewController(viewModel: viewModel)
    
    let coordinator = LogInGuideCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
