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

public protocol HomeDependency: Dependency {
  var loginContainable: LogInContainable { get }
}

public final class HomeContainer:
  Container<HomeDependency>,
  HomeContainable,
  NoneMemberHomeDependency {
  public func coordinator(listener: HomeListener) -> Coordinating {
    let viewModel = HomeViewModel()
    
    let noneMemberHome = NoneMemberHomeContainer(dependency: self)
    
    let coordinator = HomeCoordinator(
      viewModel: viewModel,
      loginContainer: dependency.loginContainable,
      noneMemberHomeContainer: noneMemberHome
    )
    coordinator.listener = listener
    return coordinator
  }
}
