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
  
  init(loggedInContainer: LoggedInContainable) {
    self.loggedInContainer = loggedInContainer
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    
    navigationController?.pushViewController(AppViewController(), animated: true)
    attachLoggedIn()
  }
  
  func attachLoggedIn() {
    if loggedInCoordinator != nil { return }
    
    let coordinator = loggedInContainer.coordinator(listener: self)
    coordinator.start(at: self.navigationController)
    
    self.loggedInCoordinator = coordinator
  }
}

// MARK: - LoggedInListener
extension AppCoordinator: LoggedInListener { }
