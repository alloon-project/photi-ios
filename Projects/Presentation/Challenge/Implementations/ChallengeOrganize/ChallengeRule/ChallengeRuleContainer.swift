//
//  ChallengeRuleContainer.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeRuleDependency: Dependency {
}

protocol ChallengeRuleContainable: Containable {
  func coordinator(listener: ChallengeRuleListener) -> ViewableCoordinating
}

final class ChallengeRuleContainer: Container<ChallengeRuleDependency>, ChallengeRuleContainable {
  func coordinator(listener: ChallengeRuleListener) -> ViewableCoordinating {
    let viewModel = ChallengeRuleViewModel()
    let viewControllerable = ChallengeRuleViewController(viewModel: viewModel)
    
    let coordinator = ChallengeRuleCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
