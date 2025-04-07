//
//  SignUpCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn

protocol SignUpViewModelable { }

protocol SignUpListener: AnyObject {
  func didFinishSignUp(userName: String)
  func didTapBackButtonAtSignUp()
}

final class SignUpCoordinator: Coordinator {
  weak var listener: SignUpListener?
  
  private let navigationControllerable: NavigationControllerable
  
  private let enterEmailContainable: EnterEmailContainable
  private var enterEmailCoordinator: Coordinating?
  
  private let enterIdContainable: EnterIdContainable
  private var enterIdCoordinator: Coordinating?
  
  private let enterPasswordContainable: EnterPasswordContainable
  private var enterPasswordCoordinator: Coordinating?
  
  init(
    navigationControllerable: NavigationControllerable,
    enterEmailContainable: EnterEmailContainable,
    enterIdContainable: EnterIdContainable,
    enterPasswordContainable: EnterPasswordContainable
  ) {
    self.navigationControllerable = navigationControllerable
    self.enterEmailContainable = enterEmailContainable
    self.enterIdContainable = enterIdContainable
    self.enterPasswordContainable = enterPasswordContainable
    super.init()
  }
  
  override func start() {
    navigationControllerable.navigationController.navigationBar.isHidden = true
    attachEnterEmail()
  }
  
  override func stop() {
    detachEnterPassword()
    detachEnterId()
    detachEnterEmail()
  }
  
  // MARK: - EnterEmail
  func attachEnterEmail() {
    guard enterEmailCoordinator == nil else { return }
    
    let coordinater = enterEmailContainable.coordinator(listener: self)
    addChild(coordinater)
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.enterEmailCoordinator = coordinater
  }
  
  func detachEnterEmail() {
    guard let coordinater = enterEmailCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: true)
    self.enterEmailCoordinator = nil
  }
  
  // MARK: - EnterId
  func attachEnterId() {
    guard enterIdCoordinator == nil else { return }
    
    let coordinater = enterIdContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: false)
    self.enterIdCoordinator = coordinater
  }
  
  func detachEnterId() {
    guard let coordinater = enterIdCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: false)
    self.enterIdCoordinator = nil
  }
  
  // MARK: - EnterPassword
  func attachEnterPassword() {
    guard enterPasswordCoordinator == nil else { return }
    
    let coordinater = enterPasswordContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: false)
    self.enterPasswordCoordinator = coordinater
  }
  
  func detachEnterPassword() {
    guard let coordinater = enterPasswordCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: false)
    self.enterPasswordCoordinator = nil
  }
}

// MARK: - EnterEmailListener
extension SignUpCoordinator: EnterEmailListener {
  func didTapBackButtonAtEnterEmail() {
    detachEnterEmail()
    listener?.didTapBackButtonAtSignUp()
  }
  
  func didFinishEnterEmail() {
    attachEnterId()
  }
}

// MARK: - EnterIdListener
extension SignUpCoordinator: EnterIdListener {
  func didTapBackButtonAtEnterId() {
    detachEnterId()
  }
  
  func didFinishEnterId() {
    attachEnterPassword()
  }
}

// MARK: - EnterPasswordListner
extension SignUpCoordinator: EnterPasswordListener {
  func didTapBackButtonAtEnterPassword() {
    detachEnterPassword()
  }
  
  func didFinishEnterPassword(userName: String) {
    listener?.didFinishSignUp(userName: userName)
  }
}
