//
//  FeedsByDateContainer.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core

protocol FeedsByDateDependency: Dependency { }

protocol FeedsByDateContainable: Containable {
  func coordinator(date: Date, listener: FeedsByDateListener) -> ViewableCoordinating
}

final class FeedsByDateContainer: Container<FeedsByDateDependency>, FeedsByDateContainable {
  func coordinator(date: Date, listener: FeedsByDateListener) -> ViewableCoordinating {
    let viewModel = FeedsByDateViewModel()
    let viewControllerable = FeedsByDateViewController(viewModel: viewModel)
    
    let coordinator = FeedsByDateCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
