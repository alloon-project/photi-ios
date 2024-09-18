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

  init(mainContainer: MainContainable) {
    self.mainContainer = mainContainer
    self.viewController = AppViewController()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    attachMain()
  }
  
  // MARK: - Main
  func attachMain() {
    if mainCoordinator != nil { return }
    
    let coordinator = mainContainer.coordinator(listener: self)
    self.addChild(coordinator)
    coordinator.start(at: self.navigationController)
    
    self.mainCoordinator = coordinator
  }
}

// MARK: - MainListener
extension AppCoordinator: MainListener { }
