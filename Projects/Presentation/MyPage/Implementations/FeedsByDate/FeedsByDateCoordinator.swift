//
//  FeedsByDateCoordinator.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import Challenge

protocol FeedsByDateListener: AnyObject {
  func didTapBackButtonAtFeedsByDate()
  func authenticateFailedAtFeedsByDate()
}

protocol FeedsByDatePresentable { }

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

// MARK: - FeedsByDateCoordinatable
extension FeedsByDateCoordinator: FeedsByDateCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtFeedsByDate()
  }
  
  func authenticateFailed() {
    listener?.authenticateFailedAtFeedsByDate()
  }
}
