//
//  ResignContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol ResignDependency: Dependency { }

public protocol ResignContainable: Containable {
  func coordinator(listener: ResignListener) -> Coordinating
}

public final class ResignContainer:
  Container<ResignDependency>,
  ResignContainable {
  public func coordinator(listener: ResignListener) -> Core.Coordinating {
    let viewModel = ResignViewModel()
    
    let coordinator = ResignCoordinator(viewModel: viewModel)
    
    coordinator.listener = listener
    
    return coordinator
  }
}
