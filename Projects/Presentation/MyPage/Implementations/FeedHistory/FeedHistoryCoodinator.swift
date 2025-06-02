//
//  FeedHistoryCoodinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core

protocol FeedHistoryListener: AnyObject {
  func didTapBackButtonAtFeedHistory()
  func authenticatedFailedAtFeedHistory()
}

protocol FeedHistoryPresentable {
  func configureProvedFeedCount(_ count: Int)
  func deleteFeed(challengeId: Int, feedId: Int)
  func deleteAllFeeds(challengeId: Int)
}

final class FeedHistoryCoordinator: ViewableCoordinator<FeedHistoryPresentable> {
  weak var listener: FeedHistoryListener?
  private let feedCount: Int
  private let viewModel: FeedHistoryViewModel
  
  private let challengeContainable: ChallengeContainable
  private var challengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FeedHistoryViewModel,
    feedCount: Int,
    challengeContainable: ChallengeContainable
  ) {
    self.viewModel = viewModel
    self.feedCount = feedCount
    self.challengeContainable = challengeContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    presenter.configureProvedFeedCount(feedCount)
  }
}

// MARK: - Challenge
extension FeedHistoryCoordinator {
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

// MARK: - FeedHistoryCoordinatable
extension FeedHistoryCoordinator: FeedHistoryCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtFeedHistory()
  }
}

// MARK: - ChallengeListener
extension FeedHistoryCoordinator: ChallengeListener {
  func authenticatedFailedAtChallenge() {
    listener?.authenticatedFailedAtFeedHistory()
  }
  
  func didTapBackButtonAtChallenge() {
    detachChallenge()
  }
  
  func shouldDismissChallenge() {
    detachChallenge()
  }
  
  func leaveChallenge(challengeId: Int) {
    detachChallenge()
    presenter.deleteAllFeeds(challengeId: challengeId)
  }
  
  func deleteFeed(challengeId: Int, feedId: Int) {
    presenter.deleteFeed(challengeId: challengeId, feedId: feedId)
  }
}
