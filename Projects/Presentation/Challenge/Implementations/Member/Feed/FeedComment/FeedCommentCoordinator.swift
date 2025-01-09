//
//  FeedDetailCoordinator.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol FeedCommentListener: AnyObject {
  func requestDismissAtFeedComment()
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
}
