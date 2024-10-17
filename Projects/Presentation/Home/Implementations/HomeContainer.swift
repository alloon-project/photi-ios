//
//  HomeContainer.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Home
import LogIn
import UseCase

public protocol HomeDependency: Dependency {
  var loginContainable: LogInContainable { get }
  var homeUseCae: HomeUseCase { get }
}

public final class HomeContainer:
  Container<HomeDependency>,
  HomeContainable,
  NoneMemberHomeDependency,
  NoneChallengeHomeDependency {
  var homeUseCase: HomeUseCase { dependency.homeUseCae }
  
  public func coordinator(listener: HomeListener) -> Coordinating {
    let viewModel = HomeViewModel(useCase: dependency.homeUseCae)
    
    let noneMemberHome = NoneMemberHomeContainer(dependency: self)
    let noneChallengeHome = NoneChallengeHomeContainer(dependency: self)
    
    let coordinator = HomeCoordinator(
      viewModel: viewModel,
      loginContainer: dependency.loginContainable,
      noneMemberHomeContainer: noneMemberHome,
      noneChallengeHomeContainer: noneChallengeHome
    )
    coordinator.listener = listener
    return coordinator
  }
}
