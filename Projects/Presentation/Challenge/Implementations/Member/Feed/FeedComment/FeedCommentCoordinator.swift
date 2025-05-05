//
//  FeedDetailCoordinator.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol FeedCommentListener: AnyObject {
  func requestReportAtFeedComment(feedId: Int)
  func requestDismissAtFeedComment()
  func deleteFeed(id: Int)
  func authenticatedFailedAtFeedComment()
  func networkUnstableAtFeedComment(reason: String?)
  func updateLikeState(feedId: Int, isLiked: Bool)
}

protocol FeedCommentPresentable { }

final class FeedCommentCoordinator: ViewableCoordinator<FeedCommentPresentable> {
  weak var listener: FeedCommentListener?

  private let viewModel: FeedCommentViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FeedCommentViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - FeedCommentCoordinatable
extension FeedCommentCoordinator: FeedCommentCoordinatable {
  func requestDismiss() {
    listener?.requestDismissAtFeedComment()
  }
  
  func deleteFeed(id: Int) {
    listener?.deleteFeed(id: id)
  }
  
  func authenticatedFailed() {
    listener?.authenticatedFailedAtFeedComment()
  }
  
  func networkUnstable(reason: String?) {
    listener?.networkUnstableAtFeedComment(reason: reason)
  }
  
  func requestReport(id: Int) {
    listener?.requestReportAtFeedComment(feedId: id)
  }
  
  func updateLikeState(feedId: Int, isLiked: Bool) {
    listener?.updateLikeState(feedId: feedId, isLiked: isLiked)
  }
}
