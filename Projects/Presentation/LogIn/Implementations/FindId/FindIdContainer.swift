//
//  FindIdContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol FindIdDependency: Dependency { }

protocol FindIdContainable: Containable {
  func coordinator(listener: FindIdListener) -> ViewableCoordinating
}

final class FindIdContainer: Container<FindIdDependency>, FindIdContainable {
  func coordinator(listener: FindIdListener) -> ViewableCoordinating {
    let viewModel = FindIdViewModel()
    let viewControllerable = FindIdViewController(viewModel: viewModel)
    let coordinator = FindIdCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
