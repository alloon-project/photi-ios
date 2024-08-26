//
//  MainContainer.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Home
import HomeImpl
import MyPageImpl
import SearchChallenge
import SearchChallengeImpl

protocol MainDependency: Dependency { }

protocol MainContainable: Containable {
  func coordinator(listener: MainListener) -> Coordinating
}

final class MainContainer:
  Container<MainDependency>,
  MainContainable,
  HomeDependency,
  SearchChallengeDependency,
  MyPageDependency {
  func coordinator(listener: MainListener) -> Coordinating {
    let home = HomeContainer(dependency: self)
    let searchChallenge = SearchChallengeContainer(dependency: self)
    let myPage = MyPageContainer(dependency: self)
    
    let coordinator = MainCoordinator(
      homeContainable: home,
      searchChallengeContainable: searchChallenge,
      myPageContainable: myPage
    )
    coordinator.listener = listener
    return coordinator
  }
}
