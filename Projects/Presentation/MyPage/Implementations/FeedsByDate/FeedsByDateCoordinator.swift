//
//  FeedsByDateCoordinator.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol FeedsByDateListener: AnyObject { }

protocol FeedsByDatePresentable { }

final class FeedsByDateCoordinator: ViewableCoordinator<FeedsByDatePresentable> {
  weak var listener: FeedsByDateListener?

  private let viewModel: FeedsByDateViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: FeedsByDateViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - FeedsByDateCoordinatable
extension FeedsByDateCoordinator: FeedsByDateCoordinatable { }
