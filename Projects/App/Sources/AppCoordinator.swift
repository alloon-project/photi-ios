//
//  AppCoordinator.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Home
import SearchChallenge
import MyPage

protocol AppPresentable {
  func attachNavigationControllers(_ viewControllerables: NavigationControllerable...)
}

final class AppCoordinator: ViewableCoordinator<AppPresentable> {
  private let homeNavigationControllerable = NavigationControllerable()
  private let searchChallengeNavigationControllerable = NavigationControllerable()
  private let myPageNavigationControllerable = NavigationControllerable()
  
  private let homeContainable: HomeContainable
  private let searchChallengeContainable: SearchChallengeContainable
  private let myPageContainable: MyPageContainable
  
  init(
    viewControllerable: ViewControllerable,
    homeContainable: HomeContainable,
    searchChallengeContainable: SearchChallengeContainable,
    myPageContainable: MyPageContainable,
  ) {
    self.homeContainable = homeContainable
    self.searchChallengeContainable = searchChallengeContainable
    self.myPageContainable = myPageContainable
    super.init(viewControllerable)
  }
  
  override func start() {
    attachCoordinators()
  }
  
  func attachCoordinators() {
    let homeCoordinator = homeContainable.coordinator(navigationControllerable: homeNavigationControllerable, listener: self)
    let searchChallengeCoordinator = searchChallengeContainable.coordinator(listener: self)
    let myPageCoordinator = myPageContainable.coordinator(listener: self)
    
    searchChallengeNavigationControllerable.setViewControllers([searchChallengeCoordinator.viewControllerable])
    myPageNavigationControllerable.setViewControllers([myPageCoordinator.viewControllerable])
        
    presenter.attachNavigationControllers(
      homeNavigationControllerable,
      searchChallengeNavigationControllerable,
      myPageNavigationControllerable
    )
    
    addChild(homeCoordinator)
    addChild(searchChallengeCoordinator)
    addChild(myPageCoordinator)
  }
}

// MARK: - HomeListener
extension AppCoordinator: HomeListener { }

// MARK: - SearchChallengeListener
extension AppCoordinator: SearchChallengeListener { }

// MARK: - MyPageListener
extension AppCoordinator: MyPageListener { }
