//
//  FeedContainer.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol FeedDependency: Dependency { }

protocol FeedContainable: Containable {
  func coordinator(listener: FeedListener) -> Coordinating
}

final class FeedContainer: Container<FeedDependency>, FeedContainable {
  func coordinator(listener: FeedListener) -> Coordinating {
    let viewModel = FeedViewModel()
    
    let coordinator = FeedCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
