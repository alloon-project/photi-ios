//
//  FeedCoordinator.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol FeedListener: AnyObject { }

final class FeedCoordinator: Coordinator {
  weak var listener: FeedListener?
  
  let viewController: FeedViewController
  private let viewModel: FeedViewModel
  
  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
    self.viewController = FeedViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
}

// MARK: - Coordinatable
extension FeedCoordinator: FeedCoordinatable { }
