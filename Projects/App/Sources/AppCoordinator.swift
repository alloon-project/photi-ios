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
  private var logInCoordinater: Coordinating?
  
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
    guard logInCoordinater == nil else { return }
    
    let coordinater = logInContainer.coordinator(listener: self)
    addChild(coordinater)
    
    self.logInCoordinater = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachLogIn() {
    guard let coordinater = logInCoordinater else { return }
    
    navigationController?.dismiss(animated: true)
    removeChild(coordinater)
    self.logInCoordinater = nil
  }
}

// MARK: - MainListener
extension AppCoordinator: MainListener { }

// MARK: - LogInListener
extension AppCoordinator: LogInListener {
  func didFinishLogIn() {
    detachLogIn()
    attachMain()
  }
}
