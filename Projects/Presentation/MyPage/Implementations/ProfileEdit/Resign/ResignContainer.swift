//
//  ResignContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol ResignDependency: Dependency { }

protocol ResignContainable: Containable {
  func coordinator(listener: ResignListener) -> ViewableCoordinating
}

final class ResignContainer:
  Container<ResignDependency>,
  ResignContainable {
  func coordinator(listener: ResignListener) -> ViewableCoordinating {
    let viewModel = ResignViewModel()
    let viewControllerable = ResignViewController(viewModel: viewModel)
    
    let coordinator = ResignCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    
    coordinator.listener = listener
    
    return coordinator
  }
}
