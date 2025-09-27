//
//  HomeContainer.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import Challenge
import Home
import UseCase

public protocol HomeDependency {
  var homeUseCae: HomeUseCase { get }
  var challengeContainable: ChallengeContainable { get }
  var noneMemberChallengeContainable: NoneMemberChallengeContainable { get }
  var challengeOrganizeContainable: ChallengeOrganizeContainable { get }
}

public final class HomeContainer:
  Container<HomeDependency>,
  HomeContainable,
  ChallengeHomeDependency,
  NoneMemberHomeDependency,
  NoneChallengeHomeDependency {
  var homeUseCase: HomeUseCase { dependency.homeUseCae }
  var noneMemberChallengeContainable: NoneMemberChallengeContainable { dependency.noneMemberChallengeContainable }
  var challengeContainable: ChallengeContainable { dependency.challengeContainable }
  var challengeOrganizeContainable: ChallengeOrganizeContainable { dependency.challengeOrganizeContainable }
  
  public func coordinator(navigationControllerable: NavigationControllerable, listener: HomeListener) -> Coordinating {
    let challengeHome = ChallengeHomeContainer(dependency: self)
    let noneMemberHome = NoneMemberHomeContainer(dependency: self)
    let noneChallengeHome = NoneChallengeHomeContainer(dependency: self)
    
    let coordinator = HomeCoordinator(
      useCase: dependency.homeUseCae,
      navigationControllerable: navigationControllerable,
      challengeHomeContainer: challengeHome,
      noneMemberHomeContainer: noneMemberHome,
      noneChallengeHomeContainer: noneChallengeHome
    )
    coordinator.listener = listener
    return coordinator
  }
}
