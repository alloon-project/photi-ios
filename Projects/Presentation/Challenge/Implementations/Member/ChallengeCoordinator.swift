//
//  ChallengeCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import Challenge

protocol ChallengeViewModelable { }

protocol ChallengePresentable {
  func attachViewControllers(_ viewControllers: UIViewController...)
  func didChangeContentOffsetAtMainContainer(_ offset: Double)
}

final class ChallengeCoordinator: Coordinator, ChallengeCoordinatable {
  weak var listener: ChallengeListener?
  
  private let viewController: ChallengeViewController
  private let viewModel: ChallengeViewModel
  
  private let feedContainer: FeedContainable
  private var feedCoordinator: FeedCoordinator?
  
  init(
    viewController: ChallengeViewController,
    viewModel: ChallengeViewModel,
    feedContainer: FeedContainable
  ) {
    self.viewController = viewController
    self.viewModel = viewModel
    self.feedContainer = feedContainer
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(self.viewController, animated: true)
    attachSegments()
  }
  
  // MARK: - Feed
  func attachSegments() {
    let feedCoordinator = feedContainer.coordinator(listener: self)
    
    // 해당 코드는 Coordinator 이후에 수정 예정입니다.
    guard let feedCoordinator = feedCoordinator as? FeedCoordinator else { return }
    self.feedCoordinator = feedCoordinator
    viewController.attachViewControllers(feedCoordinator.viewController)
  }
}

// MARK: - FeedListener
extension ChallengeCoordinator: FeedListener {  
  func didChangeContentOffsetAtFeed(_ offset: Double) {
    viewController.didChangeContentOffsetAtMainContainer(offset)
  }
}
