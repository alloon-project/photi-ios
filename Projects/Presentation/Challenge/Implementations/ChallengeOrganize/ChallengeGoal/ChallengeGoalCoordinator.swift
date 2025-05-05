//
//  ChallengeGoalCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core

protocol ChallengeGoalListener: AnyObject {
  func didTapBackButtonAtChallengeGoal()
  func didFisishChallengeGoal(challengeGoal: String, proveTime: String, endDate: Date)
}

protocol ChallengeGoalPresentable { }

final class ChallengeGoalCoordinator: ViewableCoordinator<ChallengeGoalPresentable> {
  weak var listener: ChallengeGoalListener?
  
  private let viewModel: ChallengeGoalViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeGoalViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension ChallengeGoalCoordinator: ChallengeGoalCoordinatable {
  func didFinishChallengeGoal(
    challengeGoal: String,
    proveTime: String,
    endDate: Date
  ) {
    listener?.didFisishChallengeGoal(
      challengeGoal: challengeGoal,
      proveTime: proveTime,
      endDate: endDate
    )
  }
  
  func didTapBackButtonAtChallengeGoal() {
    listener?.didTapBackButtonAtChallengeGoal()
  }
}
