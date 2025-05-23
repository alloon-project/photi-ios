//
//  AppCoordinator.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Home
import LogIn
import SearchChallenge
import MyPage

@MainActor protocol AppPresentable {
  func attachNavigationControllers(_ viewControllerables: NavigationControllerable...)
  func changeNavigationControllerToHome()
  func changeNavigationControllerToChallenge()
  func changeNavigationControllerToMyPage()
  func presentWelcomeToastView(_ username: String)
}

final class AppCoordinator: ViewableCoordinator<AppPresentable> {
  private let homeNavigationControllerable = NavigationControllerable()
  private let searchChallengeNavigationControllerable = NavigationControllerable()
  private let myPageNavigationControllerable = NavigationControllerable()
  
  private let homeContainer: HomeContainable
  private var homeCoorinator: Coordinating?
  
  private let searchChallengeContainer: SearchChallengeContainable
  private var searchChallengeCoordinator: ViewableCoordinating?
  
  private let myPageContainer: MyPageContainable
  private var myPageCoordinator: ViewableCoordinating?
  
  private let loginContainer: LogInContainable
  private var loginCoordinator: ViewableCoordinating?
  private var loginPresentNavigationControllerable: NavigationControllerable?
  
  init(
    viewControllerable: ViewControllerable,
    homeContainable: HomeContainable,
    searchChallengeContainable: SearchChallengeContainable,
    myPageContainable: MyPageContainable,
    loginContainable: LogInContainable
  ) {
    self.homeContainer = homeContainable
    self.searchChallengeContainer = searchChallengeContainable
    self.myPageContainer = myPageContainable
    self.loginContainer = loginContainable
    super.init(viewControllerable)
  }
  
  override func start() {
    Task { await attachCoordinators() }
  }
}

// MARK: - LogIn
private extension AppCoordinator {
  @MainActor func attachLogIn(at navigationController: NavigationControllerable) {
    guard loginCoordinator == nil else { return }

    let coordinator = loginContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationController.navigationController.hideTabBar(animated: true)
    navigationController.pushViewController(coordinator.viewControllerable, animated: true)
    self.loginCoordinator = coordinator
    self.loginPresentNavigationControllerable = navigationController
  }

  @MainActor func detachLogIn(willPopViewConroller: Bool) {
    guard
      let coordinator = loginCoordinator,
      let navigation = loginPresentNavigationControllerable
    else { return }

    removeChild(coordinator)
    self.loginCoordinator = nil
    self.loginPresentNavigationControllerable = nil
    
    navigation.navigationController.showTabBar(animted: true)
    if willPopViewConroller { navigation.popViewController(animated: true) }
  }
}

// MARK: - Attach Methods
private extension AppCoordinator {
  @MainActor func attachCoordinators() {
    attachHome()
    attachSearchChallenge()
    attachMyPage()
    
    presenter.attachNavigationControllers(
      homeNavigationControllerable,
      searchChallengeNavigationControllerable,
      myPageNavigationControllerable
    )
  }
  
  @MainActor func reloadAllTab() {
    detachSearchChallenge()
    detachMyPage()
    
    homeCoorinator?.start()
    attachSearchChallenge()
    attachMyPage()
  }
}

// MARK: - Home
private extension AppCoordinator {
  @MainActor func attachHome() {
    guard homeCoorinator == nil else { return }

    let coordinator = homeContainer.coordinator(
      navigationControllerable: homeNavigationControllerable,
      listener: self
    )
    addChild(coordinator)
    self.homeCoorinator = coordinator
  }
}

// MARK: - SearchChallenge
private extension AppCoordinator {
  @MainActor func attachSearchChallenge() {
    guard searchChallengeCoordinator == nil else { return }
    
    let coordinator = searchChallengeContainer.coordinator(listener: self)
    searchChallengeNavigationControllerable.setViewControllers([coordinator.viewControllerable])
    addChild(coordinator)
    self.searchChallengeCoordinator = coordinator
  }
  
  @MainActor func detachSearchChallenge() {
    guard let coordinator = searchChallengeCoordinator else { return }
    removeChild(coordinator)
    self.searchChallengeCoordinator = nil
  }
}

// MARK: - MyPage
private extension AppCoordinator {
  @MainActor func attachMyPage() {
    guard myPageCoordinator == nil else { return }
    
    let coordinator = myPageContainer.coordinator(listener: self)
    myPageNavigationControllerable.setViewControllers([coordinator.viewControllerable])
    addChild(coordinator)
    self.myPageCoordinator = coordinator
  }
  
  @MainActor func detachMyPage() {
    guard let coordinator = myPageCoordinator else { return }
    removeChild(coordinator)
    self.myPageCoordinator = nil
  }
}

// MARK: - HomeListener
extension AppCoordinator: HomeListener {
  func requestLogInAtHome() {
    Task { await attachLogIn(at: homeNavigationControllerable) }
  }

  func authenticatedFailedAtHome() {
    Task { await reloadAllTab() }
  }
}

// MARK: - SearchChallengeListener
extension AppCoordinator: SearchChallengeListener { }

// MARK: - MyPageListener
extension AppCoordinator: MyPageListener {
  func isUserResigned() {
    Task { await presenter.changeNavigationControllerToHome() }
  }
}

// MARK: - LoginListener
extension AppCoordinator: LogInListener {
  func didFinishLogIn(userName: String) {
    // TODO: - 환영합니다" 메시지 띄우기
    Task {
      await detachLogIn(willPopViewConroller: false)
      await reloadAllTab()

      await presenter.changeNavigationControllerToHome()
      await presenter.presentWelcomeToastView(ServiceConfiguration.shared.userName)
    }
  }
  
  func didTapBackButtonAtLogIn() {
    Task { await detachLogIn(willPopViewConroller: true) }
  }
}
