//
//  FeedCoordinator.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol FeedListener: AnyObject {
  func didChangeContentOffsetAtFeed(_ offset: Double)
  func requestLoginAtChallengeFeed()
  func shouldDismissChallenge()
}

protocol FeedPresentable { }

final class FeedCoordinator: ViewableCoordinator<FeedPresentable> {
  weak var listener: FeedListener?

  private let viewModel: FeedViewModel
  
  private let feedCommentContainer: FeedCommentContainable
  private var feedCommentCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FeedViewModel,
    feedCommentContainer: FeedCommentContainable
  ) {
    self.viewModel = viewModel
    self.feedCommentContainer = feedCommentContainer
    super.init(viewControllerable)
    viewModel.coordinator = self
    print(viewModel.coordinator == nil)
  }
}

// MARK: - FeedCoordinatable
extension FeedCoordinator: FeedCoordinatable {
  func attachFeedDetail(for feedID: String) {
    guard feedCommentCoordinator == nil else { return }
    let coordinator = feedCommentContainer.coordinator(listener: self, feedID: feedID)
    self.feedCommentCoordinator = coordinator
    addChild(coordinator)
    
    viewControllerable.present(
      coordinator.viewControllerable,
      animated: true,
      modalPresentationStyle: .overFullScreen
    )
  }
  
  // MARK: - Detach
  func detachFeedDetail() {
    guard let coordinator = feedCommentCoordinator else { return }
    
    removeChild(coordinator)
    coordinator.viewControllerable.dismiss(animated: false)
    self.feedCommentCoordinator = nil
  }
  
  func didChangeContentOffset(_ offset: Double) {
    listener?.didChangeContentOffsetAtFeed(offset)
  }
  
  func requestLogin() {
    listener?.requestLoginAtChallengeFeed()
  }
  
  func didTapConfirmButtonAtAlert() {
    listener?.shouldDismissChallenge()
  }
}

// MARK: - Listener
extension FeedCoordinator: FeedCommentListener {
  func requestDismissAtFeedComment() {
    detachFeedDetail()
  }
}
