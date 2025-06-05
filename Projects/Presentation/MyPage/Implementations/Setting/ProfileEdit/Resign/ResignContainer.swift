//
//  ResignContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol ResignDependency: Dependency {
  var profileEditUsecase: ProfileEditUseCase { get }
}

protocol ResignContainable: Containable {
  func coordinator(listener: ResignListener) -> ViewableCoordinating
}

final class ResignContainer:
  Container<ResignDependency>,
  ResignContainable,
  ResignAuthDependency {
  var profileEditUsecase: ProfileEditUseCase { dependency.profileEditUsecase }
  
  func coordinator(listener: ResignListener) -> ViewableCoordinating {
    let viewModel = ResignViewModel()
    let viewControllerable = ResignViewController(viewModel: viewModel)
    
    let resignAuth = ResignAuthContainer(dependency: self)
    let coordinator = ResignCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      resignAuthContainable: resignAuth
    )
    
    coordinator.listener = listener
    
    return coordinator
  }
}
