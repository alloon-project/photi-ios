//
//  EnterChallengeGoalCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol EnterChallengeGoalListener: AnyObject {
  func didTapBackButtonAtEnterChallengeGoal()
  func didFinishEnterChallengeGoal(_ goal: String)
  func authenticatedFailedAtEnterChallengeGoal()
}

protocol EnterChallengeGoalPresentable { }

final class EnterChallengeGoalCoordinator: ViewableCoordinator<EnterChallengeGoalPresentable> {
  weak var listener: EnterChallengeGoalListener?

  private let viewModel: EnterChallengeGoalViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: EnterChallengeGoalViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - EditChallengeGoalCoordinatable
extension EnterChallengeGoalCoordinator: EnterChallengeGoalCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEnterChallengeGoal()
  }
  
  func didChangeChallengeGoal(goal: String) {
    listener?.didFinishEnterChallengeGoal(goal)
  }
  
  func didSkipEnterChallengeGoal() {
    listener?.didFinishEnterChallengeGoal("")
  }
  
  func authenticatedFailed() {
    listener?.authenticatedFailedAtEnterChallengeGoal()
  }
}
