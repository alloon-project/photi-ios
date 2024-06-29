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
import MyMission
import MyPageImpl
import MyPage
import MyMissionImpl

protocol MainDependency: Dependency { }

protocol MainContainable: Containable {
  func coordinator(listener: MainListener) -> Coordinating
}

final class MainContainer:
  Container<MainDependency>,
  MainContainable,
  HomeDependency,
  MyMissionDependency,
  MyPageDependency {
  func coordinator(listener: MainListener) -> Coordinating {
    let home = HomeContainer(dependency: self)
    let myMission = MyMissionContainer(dependency: self)
    let myPage = MyPageContainer(dependency: self)
    
    let coordinator = MainCoordinator(
      homeContainable: home,
      myMissionContainable: myMission,
      myPageContainable: myPage
    )
    coordinator.listener = listener
    return coordinator
  }
}
