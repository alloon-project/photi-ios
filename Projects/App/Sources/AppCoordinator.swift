//
//  AppCoordinator.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

final class AppCoordinator: Coordinater {
  private let loggedInContainer: LoggedInContainable
  private var loggedInCoordinate: Coordinating?
  
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
    if loggedInCoordinate != nil { return }
    
    let coordinate = loggedInContainer.coordinator(listener: self)
    coordinate.start(at: self.navigationController)
    
    self.loggedInCoordinate = coordinate
  }
}

// MARK: - LoggedInListener
extension AppCoordinator: LoggedInListener { }
