//
//  HomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import Home
import LogIn

protocol HomeViewModelable { }

final class HomeCoordinator: Coordinator, HomeCoordinatable {
  weak var listener: HomeListener?
  
  private let viewController: HomeViewController
  private let viewModel: HomeViewModel
  
  private let noneMemberHomeContainer: NoneMemberHomeContainable
  private var noneMemberHomeCoordinator: Coordinating?
  
  private let noneChallengeHomeContainer: NoneChallengeHomeContainable
  private var noneChallengeHomeCoordinator: Coordinating?
  
  private let loginContainer: LogInContainable
  private var loginCoordinator: Coordinating?
  
  init(
    viewModel: HomeViewModel,
    loginContainer: LogInContainable,
    noneMemberHomeContainer: NoneMemberHomeContainable,
    noneChallengeHomeContainer: NoneChallengeHomeContainable
  ) {
    self.viewModel = viewModel
    self.loginContainer = loginContainer
    self.noneMemberHomeContainer = noneMemberHomeContainer
    self.noneChallengeHomeContainer = noneChallengeHomeContainer
    self.viewController = HomeViewController(viewModel: self.viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
    // TODO: - TOKEN에 따라 이동할지 여부 로직 구현
    attachNoneMemberHome()
  }
}

// MARK: - NoneMemberHome
private extension HomeCoordinator {
  func attachNoneMemberHome() {
    guard noneMemberHomeCoordinator == nil else { return }
    
    let coordinator = noneMemberHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    
    self.noneMemberHomeCoordinator = coordinator
    coordinator.start(at: self.navigationController)
  }
  
  func detachNoneMemberHome() {
    guard let coordinator = noneMemberHomeCoordinator else { return }
    
    removeChild(coordinator)
    self.noneMemberHomeCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - NoneChallengeHome
private extension HomeCoordinator {
  func attachNoneChallengeHome() {
    guard noneChallengeHomeCoordinator == nil else { return }
    
    let coordinator = noneChallengeHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    
    self.noneChallengeHomeCoordinator = coordinator
    coordinator.start(at: self.navigationController)
  }
  
  func detachNoneChallengeHome() {
    guard let coordinator = noneChallengeHomeCoordinator else { return }
    
    removeChild(coordinator)
    self.noneChallengeHomeCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - LogIn
private extension HomeCoordinator {
  func attachLogIn() {
    guard loginCoordinator == nil else { return }
    
    let coordinator = loginContainer.coordinator(listener: self)
    addChild(coordinator)
    
    self.loginCoordinator = coordinator
    coordinator.start(at: self.navigationController)
  }
  
  func detachLogIn() {
    guard let coordinator = loginCoordinator else { return }
    
    removeChild(coordinator)
    self.loginCoordinator = nil
    
    viewController.showTabBar(animted: false)
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - NoneMemberHomeListener
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
