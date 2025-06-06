//
//  WithdrawContainer.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import UseCase

protocol WithdrawDependency: Dependency {
  var profileEditUsecase: ProfileEditUseCase { get }
}

protocol WithdrawContainable: Containable {
  func coordinator(listener: WithdrawListener) -> ViewableCoordinating
}

final class WithdrawContainer:
  Container<WithdrawDependency>,
  WithdrawContainable,
  WithdrawAuthDependency {
  var profileEditUsecase: ProfileEditUseCase { dependency.profileEditUsecase }
  
  func coordinator(listener: WithdrawListener) -> ViewableCoordinating {
    let viewModel = WithdrawViewModel()
    let viewControllerable = WithdrawViewController(viewModel: viewModel)
    
    let withdrawAuth = WithdrawAuthContainer(dependency: self)
    let coordinator = WithdrawCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel,
      withdrawAuthContainable: withdrawAuth
    )
    
    coordinator.listener = listener
    
    return coordinator
  }
}
