//
//  DescriptionContainer.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol DescriptionDependency: Dependency { }

protocol DescriptionContainable: Containable {
  func coordinator(listener: DescriptionListener) -> ViewableCoordinating
}

final class DescriptionContainer: Container<DescriptionDependency>, DescriptionContainable {
  func coordinator(listener: DescriptionListener) -> ViewableCoordinating {
    let viewModel = DescriptionViewModel()
    let viewControllerable = DescriptionViewController(viewModel: viewModel)
    
    let coordinator = DescriptionCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
