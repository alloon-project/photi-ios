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
  
  private let viewModel: FeedHistoryViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FeedHistoryViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
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
