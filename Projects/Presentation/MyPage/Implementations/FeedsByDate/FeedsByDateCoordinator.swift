//
//  FeedsByDateCoordinator.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import Challenge

protocol FeedsByDateListener: AnyObject {
  func didTapBackButtonAtFeedsByDate()
  func authenticateFailedAtFeedsByDate()
}

protocol FeedsByDatePresentable {
  func deleteFeed(challengeId: Int, feedId: Int)
  func deleteAllFeeds(challengeId: Int)
}

final class FeedsByDateCoordinator: ViewableCoordinator<FeedsByDatePresentable> {
  weak var listener: FeedsByDateListener?

  private let viewModel: FeedsByDateViewModel
  
  private let challengeContainable: ChallengeContainable
  private var challengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FeedsByDateViewModel,
    challengeContainable: ChallengeContainable
  ) {
    self.viewModel = viewModel
    self.challengeContainable = challengeContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - Challenge
@MainActor extension FeedsByDateCoordinator {
  func attachChallengeWithFeed(challengeId: Int, feedId: Int) {
    guard challengeCoordinator == nil else { return }
    
    let coordinator = challengeContainable.coordinator(
      listener: self,
      challengeId: challengeId,
      presentType: .presentWithFeed(feedId)
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

// MARK: - FeedsByDateCoordinatable
extension FeedsByDateCoordinator: FeedsByDateCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtFeedsByDate()
  }
  
  func authenticateFailed() {
    listener?.authenticateFailedAtFeedsByDate()
  }
}

// MARK: - ChallengeListener
extension FeedsByDateCoordinator: ChallengeListener {
  func authenticatedFailedAtChallenge() {
    listener?.authenticateFailedAtFeedsByDate()
  }
  
  func didTapBackButtonAtChallenge() {
    Task { await detachChallenge() }
  }
  
  func shouldDismissChallenge() {
    Task { await detachChallenge() }
  }
  
  func leaveChallenge(challengeId: Int) {
    Task { await detachChallenge() }
    presenter.deleteAllFeeds(challengeId: challengeId)
  }
  
  func deleteFeed(challengeId: Int, feedId: Int) {
    presenter.deleteFeed(challengeId: challengeId, feedId: feedId)
  }
}
