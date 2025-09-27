//
//  NoneMemberHomeContainer.swift
//  HomeImpl
//
//  Created by jung on 9/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator

protocol NoneMemberHomeDependency { }

protocol NoneMemberHomeContainable: Containable {
  func coordinator(listener: NoneMemberHomeListener) -> ViewableCoordinating
}

final class NoneMemberHomeContainer:
  Container<NoneMemberHomeDependency>,
  NoneMemberHomeContainable {
  func coordinator(listener: NoneMemberHomeListener) -> ViewableCoordinating {
    let viewModel = NoneMemberHomeViewModel()
    let viewControllerable = NoneMemberHomeViewController(viewModel: viewModel)
    
    let coordinator = NoneMemberHomeCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    
    return coordinator
  }
}
