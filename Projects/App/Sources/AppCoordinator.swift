//
//  AppCoordinator.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import LogIn

final class AppCoordinator: Coordinator {
  private let viewController: AppViewController

  private let mainContainer: MainContainable
  private var mainCoordinator: Coordinating?
  
  private let logInContainer: LogInContainable
  private var logInCoordinator: Coordinating?
    
  init(
    mainContainer: MainContainable,
    logInContainer: LogInContainable
  ) {
    self.mainContainer = mainContainer
    self.logInContainer = logInContainer
    self.viewController = AppViewController()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    // TODO: 토큰 여부로 logIn, main결정하는 로직 추후 구현
    attachLogIn()
  }
  
  // MARK: - Main
  func attachMain() {
    if mainCoordinator != nil { return }
    
    let coordinator = mainContainer.coordinator(listener: self)
    self.addChild(coordinator)
    coordinator.start(at: self.navigationController)
    
    self.mainCoordinator = coordinator
  }
  
  // MARK: - LogIn
  func attachLogIn() {
    guard logInCoordinator == nil else { return }
    
    let coordinator = logInContainer.coordinator(listener: self)
    addChild(coordinator)
    
    self.logInCoordinator = coordinator
    coordinator.start(at: self.navigationController)
  }
  
  func detachLogIn() {
    guard let coordinator = logInCoordinator else { return }
    
    navigationController?.dismiss(animated: true)
    removeChild(coordinator)
    self.logInCoordinator = nil
  }
}

// MARK: - MainListener
extension AppCoordinator: MainListener { }

// MARK: - LogInListener
extension AppCoordinator: LogInListener {
  func didFinishLogIn(userName: String) {
    detachLogIn()
    attachMain()
  }
}
