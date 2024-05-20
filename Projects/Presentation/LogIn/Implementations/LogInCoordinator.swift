//
//  LogInCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import LogIn

protocol LogInViewModelable { }

final class LogInCoordinator: Coordinator, LogInCoordinatable {
  weak var listener: LogInListener?
  
  private let viewController: LogInViewController
  private let viewModel: any LogInViewModelType
  
  private let signUpContainable: SignUpContainable
  private var signUpCoordinator: Coordinating?
  
  init(
    signUpContainable: SignUpContainable
  ) {
    self.signUpContainable = signUpContainable
    self.viewController = LogInViewController()
    self.viewModel = LogInViewModel()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
  
  // MARK: - SignUp
  func attachSignUp() {
    guard signUpCoordinator == nil else { return }
    
    let coordinater = signUpContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.signUpCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachSignUp() {
    guard let coordinater = signUpCoordinator else { return }
    
    removeChild(coordinater)
    self.signUpCoordinator = nil
  }
}

// MARK: - SignUpListener
extension LogInCoordinator: SignUpListener { }
