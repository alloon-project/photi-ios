//
//  FeedDetailCoordinator.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol FeedCommentListener: AnyObject { }

final class FeedCommentCoordinator: Coordinator {
  weak var listener: FeedCommentListener?
  
  let viewController: FeedCommentViewController
  private let viewModel: FeedCommentViewModel
  
  init(viewModel: FeedCommentViewModel) {
    self.viewModel = viewModel
    self.viewController = FeedCommentViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - Coordinatable
extension FeedCommentCoordinator: FeedCommentCoordinatable { }
