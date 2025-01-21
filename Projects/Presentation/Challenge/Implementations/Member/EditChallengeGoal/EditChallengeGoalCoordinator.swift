//
//  EditChallengeGoalCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 1/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol EditChallengeGoalListener: AnyObject {
  func didTapBackButtonAtEditChallengeGoal()
  func didChangeChallengeGoal(_ goal: String)
}

protocol EditChallengeGoalPresentable { }

final class EditChallengeGoalCoordinator: ViewableCoordinator<EditChallengeGoalPresentable> {
  weak var listener: EditChallengeGoalListener?

  private let viewModel: EditChallengeGoalViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: EditChallengeGoalViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - EditChallengeGoalCoordinatable
extension EditChallengeGoalCoordinator: EditChallengeGoalCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEditChallengeGoal()
  }
  
  func didChangeChallengeGoal(_ goal: String) {
    listener?.didChangeChallengeGoal(goal)
  }
}
