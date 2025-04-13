//
//  ChallengeHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Challenge
import Core

protocol ChallengeHomeListener: AnyObject { }

protocol ChallengeHomePresentable { }

final class ChallengeHomeCoordinator: ViewableCoordinator<ChallengeHomePresentable>, ChallengeHomeCoordinatable {
  weak var listener: ChallengeHomeListener?

  private let viewModel: ChallengeHomeViewModel
  
  private let challengeContainer: ChallengeContainable
  private var challengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeHomeViewModel,
    challengeContainer: ChallengeContainable
  ) {
    self.viewModel = viewModel
    self.challengeContainer = challengeContainer 
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - LogIn
extension ChallengeHomeCoordinator {
  func attachLogin() { }
}
