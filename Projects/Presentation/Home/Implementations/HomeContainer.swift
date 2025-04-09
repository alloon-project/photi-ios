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
  ChallengeHomeDependency,
  NoneMemberHomeDependency,
  NoneChallengeHomeDependency {
  var homeUseCase: HomeUseCase { dependency.homeUseCae }
  
  public func coordinator(navigationControllerable: NavigationControllerable, listener: HomeListener) -> Coordinating {
    let challengeHome = ChallengeHomeContainer(dependency: self)
    let noneMemberHome = NoneMemberHomeContainer(dependency: self)
    let noneChallengeHome = NoneChallengeHomeContainer(dependency: self)
    
    let coordinator = HomeCoordinator(
      useCase: dependency.homeUseCae,
      navigationControllerable: navigationControllerable,
      loginContainer: dependency.loginContainable,
      challengeHomeContainer: challengeHome,
      noneMemberHomeContainer: noneMemberHome,
      noneChallengeHomeContainer: noneChallengeHome
    )
    coordinator.listener = listener
    return coordinator
  }
}
