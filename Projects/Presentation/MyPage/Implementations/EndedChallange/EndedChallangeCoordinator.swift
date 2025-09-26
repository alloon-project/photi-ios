//
//  EndedChallengeCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator
import Challenge

protocol EndedChallengeListener: AnyObject {
  func didTapBackButtonAtEndedChallenge()
  func authenticatedFailedAtEndedChallenge()
}

protocol EndedChallangePresentable {
  func configureEndedChallengeCount(_ count: Int)
}

final class EndedChallengeCoordinator: ViewableCoordinator<EndedChallangePresentable> {
  weak var listener: EndedChallengeListener?
  
  private let endedChallengeCount: Int
  private let viewModel: EndedChallengeViewModel
  
  private let challengeContainable: ChallengeContainable
  private var challengeCoordinator: ViewableCoordinating?
  
  init(
    endedChallengeCount: Int,
    viewControllerable: ViewControllerable,
    viewModel: EndedChallengeViewModel,
    challengeContainable: ChallengeContainable
  ) {
    self.endedChallengeCount = endedChallengeCount
    self.viewModel = viewModel
    self.challengeContainable = challengeContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    super.start()
    presenter.configureEndedChallengeCount(endedChallengeCount)
  }
}

// MARK: - Challenge
@MainActor extension EndedChallengeCoordinator {
  func attachChallenge(id: Int) {
    guard challengeCoordinator == nil else { return }
    
    let coordinator = challengeContainable.coordinator(
      listener: self,
      challengeId: id,
      presentType: .default
    )
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    addChild(coordinator)
    challengeCoordinator = coordinator
  }
  
  func detachChallenge() {
    guard let coordinator = challengeCoordinator else { return }
    
    viewControllerable.popViewController(animated: true)
    removeChild(coordinator)
    challengeCoordinator = nil
  }
}

// MARK: - EndedChallengeCoordinatable
extension EndedChallengeCoordinator: EndedChallengeCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEndedChallenge()
  }
  
  func authenticateFailed() {
    listener?.authenticatedFailedAtEndedChallenge()
  }
}

// MARK: - Extension
extension EndedChallengeCoordinator: ChallengeListener {
  func authenticatedFailedAtChallenge() {
    listener?.authenticatedFailedAtEndedChallenge()
  }
  
  func didTapBackButtonAtChallenge() {
    Task { await detachChallenge() }
  }
  
  func shouldDismissChallenge() {
    Task { await detachChallenge() }
  }
  
  func leaveChallenge(challengeId: Int) {
    Task { await detachChallenge() }
  }
}
