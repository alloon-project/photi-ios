//
//  ParticipantCoordinator.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator

protocol ParticipantListener: AnyObject {
  func didChangeContentOffsetAtParticipant(_ offset: Double)
  func authenticatedFailedAtParticipant()
  func networkUnstableAtParticipant()
}

protocol ParticipantPresentable {
  func didUpdateGoal(_ goal: String)
}

final class ParticipantCoordinator: ViewableCoordinator<ParticipantPresentable> {
  weak var listener: ParticipantListener?

  private let viewModel: ParticipantViewModel
  
  private let editChallengeGoalContainer: EnterChallengeGoalContainable
  private var editChallengeGoalCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ParticipantViewModel,
    editChallengeGoalContainer: EnterChallengeGoalContainer
  ) {
    self.viewModel = viewModel
    self.editChallengeGoalContainer = editChallengeGoalContainer
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - ParticipantCoordinatable
extension ParticipantCoordinator: ParticipantCoordinatable {
  func didChangeContentOffset(_ offset: Double) {
    listener?.didChangeContentOffsetAtParticipant(offset)
  }
  
  func didTapEditButton(goal: String) {
    Task { await attachEditChallengeGoal(goal: goal) }
  }
  
  func authenticatedFailed() {
    listener?.authenticatedFailedAtParticipant()
  }
  
  func networkUnstable() {
    listener?.networkUnstableAtParticipant()
  }
}

// MARK: - EditChallengeGoal
@MainActor extension ParticipantCoordinator {
  func attachEditChallengeGoal(goal: String) {
    guard editChallengeGoalCoordinator == nil else { return }
    
    let coordinator = editChallengeGoalContainer.coordinator(
      mode: .edit(goal: goal),
      challengeID: viewModel.challengeId,
      challengeName: viewModel.challengeName,
      listener: self
    )
    
    addChild(coordinator)
    self.editChallengeGoalCoordinator = coordinator
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
  }
  
  func detachEditChallengeGoal(completion: (() -> Void)? = nil) {
    guard let coordinator = editChallengeGoalCoordinator else { return }
    
    removeChild(coordinator)
    self.editChallengeGoalCoordinator = nil
    viewControllerable.popViewController(animated: true) {
      completion?()
    }
  }
}

// MARK: - EditChallengeGoalListener
extension ParticipantCoordinator: EnterChallengeGoalListener {
  func didTapBackButtonAtEnterChallengeGoal() {
    Task { await detachEditChallengeGoal() }
  }
  
  func didFinishEnteringGoal(_ goal: String) {
    Task { @MainActor in
      detachEditChallengeGoal { [weak self] in
        self?.presenter.didUpdateGoal(goal)
      }
    }
  }
  
  func authenticatedFailedAtEnterChallengeGoal() {
    listener?.authenticatedFailedAtParticipant()
  }
}
