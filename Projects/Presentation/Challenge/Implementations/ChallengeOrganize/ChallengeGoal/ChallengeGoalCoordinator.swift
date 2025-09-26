//
//  ChallengeGoalCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator

protocol ChallengeGoalListener: AnyObject {
  func didTapBackButtonAtChallengeGoal()
  func didFisishChallengeGoal(challengeGoal: String, proveTime: String, endDate: String)
}

protocol ChallengeGoalPresentable {
  func setChallengeGoal(goal: String, proveTime: String, endDate: String)
}

final class ChallengeGoalCoordinator: ViewableCoordinator<ChallengeGoalPresentable> {
  weak var listener: ChallengeGoalListener?
  
  private let viewModel: ChallengeGoalViewModel
  
  private var goal: String?
  private var proveTime: String?
  private var endDate: String?
  
  init(
    viewControllerable: ViewControllerable,
    goal: String?,
    proveTime: String?,
    endDate: String?,
    viewModel: ChallengeGoalViewModel
  ) {
    self.viewModel = viewModel
    self.goal = goal
    self.proveTime = proveTime
    self.endDate = endDate
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    guard
      let goal,
      let proveTime,
      let endDate
    else { return }
    presenter.setChallengeGoal(goal: goal, proveTime: proveTime, endDate: endDate)
  }
}

extension ChallengeGoalCoordinator: ChallengeGoalCoordinatable {
  func didFinishChallengeGoal(
    challengeGoal: String,
    proveTime: String,
    endDate: String
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
