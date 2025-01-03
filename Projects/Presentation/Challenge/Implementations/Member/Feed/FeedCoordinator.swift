//
//  FeedCoordinator.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol FeedListener: AnyObject {
  func didChangeContentOffsetAtFeed(_ offset: Double)
}

final class FeedCoordinator: Coordinator {
  weak var listener: FeedListener?
  
  let viewController: FeedViewController
  private let viewModel: FeedViewModel
  
  private let feedDetailContainer: FeedCommentContainable
  private var feedDetailCoordinator: Coordinating?
  
  init(
    viewModel: FeedViewModel,
    feedDetailContainer: FeedCommentContainable
  ) {
    self.viewModel = viewModel
    self.feedDetailContainer = feedDetailContainer
    self.viewController = FeedViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
}

// MARK: - Coordinatable
extension FeedCoordinator: FeedCoordinatable {
  func attachFeedDetail(for feedID: String) {
    guard feedDetailCoordinator == nil else { return }
    
    let coordinator = feedDetailContainer.coordinator(listener: self, feedID: feedID)
    self.feedDetailCoordinator = coordinator
    addChild(coordinator)
    
    // TODO: - Coordinator 리팩토링 후 수정 예정
    guard let coordinator = coordinator as? FeedCommentCoordinator else { return }
    
    coordinator.viewController.modalPresentationStyle = .overFullScreen
    self.viewController.present(coordinator.viewController, animated: false)
  }
  
  // MARK: - Detach
  func detachFeedDetail() {
    guard let coordinator = feedDetailCoordinator else { return }
    
    removeChild(coordinator)
    self.feedDetailCoordinator = nil
    
  }
  
  func didChangeContentOffset(_ offset: Double) {
    listener?.didChangeContentOffsetAtFeed(offset)
  }
}

// MARK: - Listener
extension FeedCoordinator: FeedCommentListener { }
