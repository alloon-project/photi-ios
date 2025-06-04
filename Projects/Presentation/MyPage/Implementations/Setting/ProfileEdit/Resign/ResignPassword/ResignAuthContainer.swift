//
//  ResignAuthContainer.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ResignAuthDependency: Dependency {
  var resignUseCase: ResignUseCase { get }
}

protocol ResignAuthContainable: Containable {
  func coordinator(listener: ResignAuthListener) -> ViewableCoordinating
}

final class ResignAuthContainer: Container<ResignAuthDependency>, ResignAuthContainable {
  func coordinator(listener: ResignAuthListener) -> ViewableCoordinating {
    let viewModel = ResignAuthViewModel(useCase: dependency.resignUseCase)
    let viewControllerable = ResignAuthViewController(viewModel: viewModel)
    let coordinator = ResignAuthCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
