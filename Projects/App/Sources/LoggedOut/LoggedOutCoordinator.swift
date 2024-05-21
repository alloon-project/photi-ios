//
//  LoggedOutCoordinator.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import LogIn

protocol LoggedOutListener: AnyObject {
  func didFinishLoggedOut()
}

final class LoggedOutCoordinator: Coordinator {
  weak var listener: LoggedOutListener?
  
  private let viewController: LoggedOutViewController
  
  private let logInContainable: LogInContainable
  private var logInCoordinater: Coordinating?
  
  init(logInContainable: LogInContainable) {
    self.logInContainable = logInContainable
    self.viewController = LoggedOutViewController()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    
    navigationController?.pushViewController(viewController, animated: false)
    
    attachLogIn()
  }
  
  override func stop() {
    super.stop()
    listener?.didFinishLoggedOut()
  }
  
  func attachLogIn() {
    guard logInCoordinater == nil else { return }
    
    let coordinater = logInContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.logInCoordinater = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachLogIn() {
    guard let coordinater = logInCoordinater else { return }
    
    removeChild(coordinater)
    self.logInCoordinater = nil
  }
}

// MARK: - LogInListener
extension LoggedOutCoordinator: LogInListener { }
