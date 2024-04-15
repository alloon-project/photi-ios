//
//  AppCoordinator.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

final class AppCoordinator: Coordinator {
  private let loggedInContainer: LoggedInContainable
  private var loggedInCoordinator: Coordinating?
  
  private let loggedOutContainer: LoggedOutContainable
  private var loggedOutCoordinator: Coordinating?
  
  init(
    loggedInContainer: LoggedInContainable,
    loggedOutContainer: LoggedOutContainable
  ) {
    self.loggedInContainer = loggedInContainer
    self.loggedOutContainer = loggedOutContainer
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    
    navigationController?.pushViewController(AppViewController(), animated: true)
    attachLoggedOut()
  }
  
  func attachLoggedIn() {
    if loggedInCoordinator != nil { return }
    
    let coordinator = loggedInContainer.coordinator(listener: self)
    self.addChild(coordinator)
    coordinator.start(at: self.navigationController)
    
    self.loggedInCoordinator = coordinator
  }
  
  func attachLoggedOut() { 
    if loggedOutCoordinator != nil { return }
    
    let coordinator = loggedOutContainer.coordinator(listener: self)
    self.addChild(coordinator)
    coordinator.start(at: self.navigationController)
    
    self.loggedOutCoordinator = coordinator
  }
  
  func detachLoggedOut() { 
    guard let coordinator = loggedOutCoordinator else { return }
    
    removeChild(coordinator)
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - LoggedInListener
extension AppCoordinator: LoggedInListener { }

// MARK: - LoggedOutListener
extension AppCoordinator: LoggedOutListener {
  func didFinishLoggedOut() {
    detachLoggedOut()
    attachLoggedIn()
  }
}
