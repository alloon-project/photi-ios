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
}

protocol FeedHistoryPresentable {
  func setMyFeedCount(_ count: Int)
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
    presenter.setMyFeedCount(feedCount)
  }
}

// MARK: - FeedHistoryCoordinatable
extension FeedHistoryCoordinator: FeedHistoryCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtFeedHistory()
  }
  
  func attachChallengeDetail() { }
  
  func detachChallengeDetail() { }
}
