//
//  ChallengeOrganizeContainer.swift
//  HomeImpl
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeOrganizeDependency: Dependency { }

protocol ChallengeOrganizeContainable: Containable {
  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: ChallengeOrganizeListener
  ) -> ViewableCoordinating
}

final class ChallengeOrganizeContainer: Container<ChallengeOrganizeDependency>, ChallengeOrganizeContainable {
  func coordinator(
    navigationControllerable: NavigationControllerable,
    listener: ChallengeOrganizeListener
  ) -> ViewableCoordinating {
    let viewModel = ChallengeOrganizeViewModel()
    let viewControllerable = ChallengeOrganizeViewController(viewModel: viewModel)
    let coordinator = ChallengeOrganizeCoordinator(
      navigationControllerable: navigationControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}

