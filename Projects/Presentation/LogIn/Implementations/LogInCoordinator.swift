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
  
  private let findIdContainable: FindIdContainable
  private var findIdCoordinator: Coordinating?
  
  private let findPasswordContainable: FindPasswordContainable
  private var findPasswordCoordinator: Coordinating?
  
  init(
    viewModel: LogInViewModel,
    signUpContainable: SignUpContainable,
    findIdContainable: FindIdContainable,
    findPasswordContainable: FindPasswordContainable
  ) {
    self.viewModel = viewModel
    self.signUpContainable = signUpContainable
    self.findIdContainable = findIdContainable
    self.findPasswordContainable = findPasswordContainable
  
    self.viewController = LogInViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
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
    
    navigationController?.popViewController(animated: true)
    removeChild(coordinater)
    self.signUpCoordinator = nil
  }
  
  // MARK: - FindId
  func attachFindId() { 
    guard findIdCoordinator == nil else { return }
    
    let coordinater = findIdContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.findIdCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachFindId() { 
    guard let coordinater = findIdCoordinator else { return }
    
    removeChild(coordinater)
    self.findIdCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - FindPassword
  func attachFindPassword() {
    guard findPasswordCoordinator == nil else { return }
    
    let coordinater = findPasswordContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.findPasswordCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachFindPassword() { 
    guard let coordinater = findPasswordCoordinator else { return }
    
    removeChild(coordinater)
    self.findPasswordCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - SignUpListener
extension LogInCoordinator: SignUpListener {
  func didFinishSignUp() {
    detachSignUp()
  }
}

// MARK: - FindpasswordListener
extension LogInCoordinator: FindPasswordListener {
  func findPasswordDidFinish() {
  }
}

// MARK: - FindIdListener
extension LogInCoordinator: FindIdListener {
  func didTapBackButtonAtFindId() {
    detachFindId()
  }
  
  func didFinishAtFindId() {
    detachFindId()
  }
}
