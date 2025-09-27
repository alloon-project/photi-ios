//
//  AppCoordinator.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator
import Core
import Home
import LogIn
import SearchChallenge
import MyPage

@MainActor protocol AppPresentable {
  func attachNavigationControllers(_ viewControllerables: NavigationControllerable...)
  func changeNavigationControllerToHome()
  func presentWelcomeToastView(_ username: String)
  func presentTokenExpiredAlertView(to navigationControllerable: NavigationControllerable)
  func presentTabMyPageWithoutLogInAlertView(to navigationControllerable: NavigationControllerable)
  func presentLogOutToastView(to navigationControllerable: NavigationControllerable)
  func presentWithdrawToastView(to navigationControllerable: NavigationControllerable)
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
    searchChallengeNavigationControllerable.setViewControllers([coordinator.viewControllerable], animated: true)
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
    myPageNavigationControllerable.setViewControllers([coordinator.viewControllerable], animated: true)
    addChild(coordinator)
    self.myPageCoordinator = coordinator
  }
  
  @MainActor func detachMyPage() {
    guard let coordinator = myPageCoordinator else { return }
    removeChild(coordinator)
    self.myPageCoordinator = nil
  }
}

// MARK: - AppCoordinatable
extension AppCoordinator: AppCoordinatable {
  func shouldReloadAllPage() {
    Task {
      await reloadAllTab()
      await presenter.changeNavigationControllerToHome()
      await presenter.presentTabMyPageWithoutLogInAlertView(to: homeNavigationControllerable)
    }
  }
  
  func attachLogIn() {
    Task { await attachLogIn(at: homeNavigationControllerable) }
  }
}

// MARK: - HomeListener
extension AppCoordinator: HomeListener {
  func requestLogInAtHome() {
    Task { await attachLogIn(at: homeNavigationControllerable) }
  }

  func authenticatedFailedAtHome() {
    Task {
      await reloadAllTab()
      await presenter.presentTokenExpiredAlertView(to: homeNavigationControllerable)
    }
  }
}

// MARK: - SearchChallengeListener
extension AppCoordinator: SearchChallengeListener {
  func authenticatedFailedAtSearchChallenge() {
    Task {
      await reloadAllTab()
      await presenter.changeNavigationControllerToHome()
      await presenter.presentTokenExpiredAlertView(to: homeNavigationControllerable)
    }
  }
  
  func attachLoginPopup() {
    Task {
      await reloadAllTab()
      await presenter.changeNavigationControllerToHome()
      await presenter.presentTabMyPageWithoutLogInAlertView(to: homeNavigationControllerable)
    }
  }
  
  func didLoginAtSearchChallenge() {
    Task {
      await MainActor.run {
        homeCoorinator?.start()
      }
    }
  }
}

// MARK: - MyPageListener
extension AppCoordinator: MyPageListener {
  func didFinishWithdrawal() {
    Task {
      await reloadAllTab()
      await presenter.changeNavigationControllerToHome()
      await presenter.presentWithdrawToastView(to: homeNavigationControllerable)
    }
  }
  
  func authenticatedFailedAtMyPage() {
    Task {
      await reloadAllTab()
      await presenter.changeNavigationControllerToHome()
      await presenter.presentTokenExpiredAlertView(to: homeNavigationControllerable)
    }
  }
  
  func didLogOut() {
    Task {
      await reloadAllTab()
      await presenter.changeNavigationControllerToHome()
      await presenter.presentLogOutToastView(to: homeNavigationControllerable)
    }
  }
}

// MARK: - LoginListener
extension AppCoordinator: LogInListener {
  func didFinishLogIn(userName: String) {
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
