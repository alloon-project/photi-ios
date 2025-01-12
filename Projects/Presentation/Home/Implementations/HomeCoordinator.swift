//
//  HomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Home
import LogIn

final class HomeCoordinator: Coordinator {
  weak var listener: HomeListener?
  private let navigationControllerable: NavigationControllerable
  
  private let challengeHomeContainer: ChallengeHomeContainable
  private var challengeHomeCoordinator: ViewableCoordinating?

  private let noneMemberHomeContainer: NoneMemberHomeContainable
  private var noneMemberHomeCoordinator: ViewableCoordinating?
  
  private let noneChallengeHomeContainer: NoneChallengeHomeContainable
  private var noneChallengeHomeCoordinator: ViewableCoordinating?
  
  private let loginContainer: LogInContainable
  private var loginCoordinator: ViewableCoordinating?
  
  init(
    navigationControllerable: NavigationControllerable,
    loginContainer: LogInContainable,
    challengeHomeContainer: ChallengeHomeContainable,
    noneMemberHomeContainer: NoneMemberHomeContainable,
    noneChallengeHomeContainer: NoneChallengeHomeContainable
  ) {
    self.navigationControllerable = navigationControllerable
    self.loginContainer = loginContainer
    self.challengeHomeContainer = challengeHomeContainer
    self.noneMemberHomeContainer = noneMemberHomeContainer
    self.noneChallengeHomeContainer = noneChallengeHomeContainer
    super.init()
  }
  
  override func start() {
    // TODO: - Token에 따라 어떤 Home으로 갈지 로직 구현
    attachNoneMemberHome()
  }
}

// MARK: - ChallengeHome
private extension HomeCoordinator {
  func attachChallengeHome() {
    guard challengeHomeCoordinator == nil else { return }
    
    let coordinator = challengeHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationControllerable.setViewControllers([coordinator.viewControllerable])

    self.noneChallengeHomeCoordinator = coordinator
  }
  
  func detachChallengeHome() {
    guard let coordinator = noneChallengeHomeCoordinator else { return }
    
    removeChild(coordinator)
    navigationControllerable.popViewController(animated: false)
    self.noneChallengeHomeCoordinator = nil
  }
}

// MARK: - NoneChallengeHome
private extension HomeCoordinator {
  func attachNoneChallengeHome() {
    guard noneChallengeHomeCoordinator == nil else { return }
    
    let coordinator = noneChallengeHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationControllerable.setViewControllers([coordinator.viewControllerable])

    self.noneChallengeHomeCoordinator = coordinator
  }
  
  func detachNoneChallengeHome() {
    guard let coordinator = noneChallengeHomeCoordinator else { return }
    
    removeChild(coordinator)
    coordinator.viewControllerable.dismiss()
    self.noneChallengeHomeCoordinator = nil
  }
}

// MARK: - NoneMemberHome
private extension HomeCoordinator {
  func attachNoneMemberHome() {
    guard noneMemberHomeCoordinator == nil else { return }
    let coordinator = noneMemberHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    
    navigationControllerable.setViewControllers([coordinator.viewControllerable])

    self.noneMemberHomeCoordinator = coordinator
  }
  
  func detachNoneMemberHome() {
    guard let coordinator = noneMemberHomeCoordinator else { return }
    
    removeChild(coordinator)
    navigationControllerable.popViewController(animated: false)
    self.noneMemberHomeCoordinator = nil
  }
}

// MARK: - LogIn
private extension HomeCoordinator {
  func attachLogIn() {
    guard loginCoordinator == nil else { return }
    
    let coordinator = loginContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationControllerable.navigationController.hideTabBar(animated: true)
    navigationControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.loginCoordinator = coordinator
  }
  
  func detachLogIn() {
    guard let coordinator = loginCoordinator else { return }
    
    removeChild(coordinator)
    self.loginCoordinator = nil
    
    navigationControllerable.navigationController.showTabBar(animted: true)
    navigationControllerable.popViewController(animated: true)
  }
}

// MARK: - ChallengeHome Listener
extension HomeCoordinator: ChallengeHomeListener { }

// MARK: - NoneMemberHome Listener
extension HomeCoordinator: NoneMemberHomeListener {
  func didTapLogInButtonAtNoneMemberHome() {
    attachLogIn()
  }
}

// MARK: - NoneChallengeHomeListener
extension HomeCoordinator: NoneChallengeHomeListener { }

// MARK: - LogInListener
extension HomeCoordinator: LogInListener {
  func didTapBackButtonAtLogIn() {
    detachLogIn()
  }
  
  public func didFinishLogIn(userName: String) {
    detachLogIn()
  }
}
