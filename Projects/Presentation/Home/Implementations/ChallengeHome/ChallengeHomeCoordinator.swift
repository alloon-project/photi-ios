//
//  ChallengeHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import Challenge

protocol ChallengeHomeListener: AnyObject {
  func authenticatedFailedAtChallengeHome()
  func requestNoneChallengeHomeAtChallengeHome()
}

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
  
  func authenticatedFailed() {
    listener?.authenticatedFailedAtChallengeHome()
  }
  
  func requestNoneChallengeHome() {
    listener?.requestNoneChallengeHomeAtChallengeHome()
  }
}

// MARK: - Challenge
@MainActor extension ChallengeHomeCoordinator {
  func attachChallenge(id: Int) {
    guard challengeCoordinator == nil else { return }
    
    let coordinator = challengeContainer.coordinator(
      listener: self,
      challengeId: id,
      presentType: .default
    )
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    
    self.challengeCoordinator = coordinator
  }
  
  func attachChallengeWithFeed(challengeId: Int, feedId: Int) {
    guard challengeCoordinator == nil else { return }
    
    let coordinator = challengeContainer.coordinator(
      listener: self,
      challengeId: challengeId,
      presentType: .presentWithFeed(feedId)
    )
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    
    self.challengeCoordinator = coordinator
  }
  
  func detachChallenge() {
    guard let coordinator = challengeCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    viewControllerable.uiviewController.showTabBar(animted: true)
    self.challengeCoordinator = nil
  }
}

// MARK: - ChallengeListener
extension ChallengeHomeCoordinator: ChallengeListener {
  func authenticatedFailedAtChallenge() {
    listener?.authenticatedFailedAtChallengeHome()
  }
  
  func didTapBackButtonAtChallenge() {
    Task { await detachChallenge() }
  }
  
  func shouldDismissChallenge() {
    Task { await detachChallenge() }
  }

  func leaveChallenge(challengeId: Int) {
    Task { await detachChallenge() }
    viewModel.reloadData()
  }
}
