//
//  SignUpCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import LogIn

protocol SignUpViewModelable { }

final class SignUpCoordinator: Coordinator, SignUpCoordinatable {
  weak var listener: SignUpListener?
  
  private let viewModel: SignUpViewModel
  
  private let enterEmailContainable: EnterEmailContainable
  private var enterEmailCoordinator: Coordinating?
  
  private let enterIdContainable: EnterIdContainable
  private var enterIdCoordinator: Coordinating?
  
  private let enterPasswordContainable: EnterPasswordContainable
  private var enterPasswordCoordinator: Coordinating?
  
  init(
    viewModel: SignUpViewModel,
    enterEmailContainable: EnterEmailContainable,
    enterIdContainable: EnterIdContainable,
    enterPasswordContainable: EnterPasswordContainable
  ) {
    self.viewModel = viewModel
    self.enterEmailContainable = enterEmailContainable
    self.enterIdContainable = enterIdContainable
    self.enterPasswordContainable = enterPasswordContainable
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    attachEnterEmail()
  }
  
  override func stop() {
    super.stop()
    detachEnterPassword(animated: false)
    detachEnterId(animated: false)
    detachEnterEmail(animated: true)
  }
  
  // MARK: - EnterEmail
  func attachEnterEmail() {
    guard enterEmailCoordinator == nil else { return }
    
    let coordinater = enterEmailContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.enterEmailCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachEnterEmail(animated: Bool) {
    guard let coordinater = enterEmailCoordinator else { return }
    
    removeChild(coordinater)
    self.enterEmailCoordinator = nil
    navigationController?.popViewController(animated: animated)
  }
  
  // MARK: - EnterId
  func attachEnterId() {
    guard enterIdCoordinator == nil else { return }
    
    let coordinater = enterIdContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.enterIdCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachEnterId(animated: Bool) {
    guard let coordinater = enterIdCoordinator else { return }
    
    removeChild(coordinater)
    self.enterIdCoordinator = nil
    navigationController?.popViewController(animated: animated)
  }
  
  // MARK: - EnterPassword
  func attachEnterPassword() {
    guard enterPasswordCoordinator == nil else { return }
    
    let coordinater = enterPasswordContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.enterPasswordCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachEnterPassword(animated: Bool) {
    guard let coordinater = enterPasswordCoordinator else { return }
    
    removeChild(coordinater)
    self.enterPasswordCoordinator = nil
    navigationController?.popViewController(animated: animated)
  }
}

// MARK: - EnterEmailListener
extension SignUpCoordinator: EnterEmailListener {
  func enterEmailDidTapBackButton() {
    listener?.didFinishSignUp()
  }
  
  func enterEmailDidFinish() {
    attachEnterId()
  }
}

// MARK: - EnterIdListener
extension SignUpCoordinator: EnterIdListener {
  func didTapBackButtonAtEnterId() {
    detachEnterId(animated: true)
  }
  
  func didFinishAtEnterId() {
    attachEnterPassword()
  }
}

// MARK: - EnterPasswordListner
extension SignUpCoordinator: EnterPasswordListener {
  func didTapBackButtonAtEnterPassword() {
    detachEnterPassword(animated: true)
  }
  
  func didFinishEnterPassword() {
    listener?.didFinishSignUp()
  }
}
