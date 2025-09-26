//
//  FeedCoordinator.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator
import Challenge

protocol FeedListener: AnyObject {
  func didChangeContentOffsetAtFeed(_ offset: Double)
  func authenticatedFailedAtFeed()
  func networkUnstableAtFeed(reason: String?)
  func challengeNotFoundAtFeed()
  func requestReportAtFeed(feedId: Int)
  func deleteFeed(challengeId: Int, feedId: Int)
}

protocol FeedPresentable {
  func deleteFeed(feedId: Int)
  func updateLikeState(feedId: Int, isLiked: Bool)
}

final class FeedCoordinator: ViewableCoordinator<FeedPresentable> {
  weak var listener: FeedListener?
  
  private var viewDidAppeared: Bool = false
  private let challengeName: String
  private let challengeId: Int
  private let viewModel: FeedViewModel
  private let initialPresentType: ChallengePresentType
  
  private let feedCommentContainer: FeedCommentContainable
  private var feedCommentCoordinator: ViewableCoordinating?
  
  init(
    challengeName: String,
    challengeId: Int,
    viewControllerable: ViewControllerable,
    viewModel: FeedViewModel,
    initialPresentType: ChallengePresentType,
    feedCommentContainer: FeedCommentContainable
  ) {
    self.challengeName = challengeName
    self.challengeId = challengeId
    self.viewModel = viewModel
    self.initialPresentType = initialPresentType
    self.feedCommentContainer = feedCommentContainer
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func viewDidAppear() {
    guard case let .presentWithFeed(feedId) = initialPresentType, !viewDidAppeared else { return }
    
    viewDidAppeared = true
    Task { await attachFeedDetail(challengeId: challengeId, feedId: feedId) }
  }
}

// MARK: - FeedDetail
@MainActor extension FeedCoordinator {
  func attachFeedDetail(challengeId: Int, feedId: Int) {
    guard feedCommentCoordinator == nil else { return }
    let coordinator = feedCommentContainer.coordinator(
      listener: self,
      challengeName: challengeName,
      challengeId: challengeId,
      feedId: feedId
    )
    self.feedCommentCoordinator = coordinator
    addChild(coordinator)
    
    viewControllerable.present(
      coordinator.viewControllerable,
      animated: false,
      modalPresentationStyle: .overFullScreen
    )
  }
  
  func detachFeedDetail(completion: (() -> Void)? = nil) {
    guard let coordinator = feedCommentCoordinator else { return }
    
    removeChild(coordinator)
    coordinator.viewControllerable.dismiss(animated: true) {
      completion?()
    }
    self.feedCommentCoordinator = nil
  }
}

// MARK: - FeedCoordinatable
extension FeedCoordinator: FeedCoordinatable {
  func didChangeContentOffset(_ offset: Double) {
    listener?.didChangeContentOffsetAtFeed(offset)
  }
  
  func authenticatedFailed() {
    listener?.authenticatedFailedAtFeed()
  }

  func networkUnstable() {
    listener?.networkUnstableAtFeed(reason: nil)
  }
  
  func challengeNotFound() {
    listener?.challengeNotFoundAtFeed()
  }
}

// MARK: - Listener
extension FeedCoordinator: FeedCommentListener {
  func requestDismissAtFeedComment() {
    Task { await detachFeedDetail() }
  }
  
  func deleteFeed(id: Int) {
    Task { @MainActor in
      detachFeedDetail { [weak self] in
        self?.presenter.deleteFeed(feedId: id)
      }
      viewModel.updateIsProveIfNeeded()
      listener?.deleteFeed(challengeId: challengeId, feedId: id)
    }
  }
  
  func authenticatedFailedAtFeedComment() {
    Task { @MainActor in
      detachFeedDetail { [weak self] in
        self?.listener?.authenticatedFailedAtFeed()
      }
    }
  }
  
  func networkUnstableAtFeedComment(reason: String?) {
    Task { @MainActor in
      detachFeedDetail { [weak self] in
        self?.listener?.networkUnstableAtFeed(reason: reason)
      }
    }
  }
  
  func requestReportAtFeedComment(feedId: Int) {
    Task { @MainActor in
      detachFeedDetail { [weak self] in
        self?.listener?.requestReportAtFeed(feedId: feedId)
      }
    }
  }
  
  func updateLikeState(feedId: Int, isLiked: Bool) {
    presenter.updateLikeState(feedId: feedId, isLiked: isLiked)
  }
}
