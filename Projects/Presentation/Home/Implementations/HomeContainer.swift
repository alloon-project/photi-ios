//
//  HomeContainer.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Home

public protocol HomeDependency: Dependency { }

public final class HomeContainer: Container<HomeDependency>, HomeContainable {
  public func coordinator(listener: HomeListener) -> Coordinating {
    let viewModel = HomeViewModel()
    
    let coordinator = HomeCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
