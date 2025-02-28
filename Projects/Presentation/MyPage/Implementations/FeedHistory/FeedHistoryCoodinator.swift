//
//  FeedHistoryCoodinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol FeedHistoryListener: AnyObject {
  func didTapBackButtonAtFeedHistory()
}

protocol FeedHistoryPresentable {
  func setProofCount(_ count: Int)
}

final class FeedHistoryCoordinator: ViewableCoordinator<FeedHistoryPresentable> {
  weak var listener: FeedHistoryListener?
  private let feedCount: Int
  private let viewModel: FeedHistoryViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FeedHistoryViewModel,
    feedCount: Int
  ) {
    self.viewModel = viewModel
    self.feedCount = feedCount
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    presenter.setProofCount(feedCount)
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
