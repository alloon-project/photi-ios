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
  
  init(
    viewModel: SignUpViewModel,
    enterEmailContainable: EnterEmailContainable,
    enterIdContainable: EnterIdContainable
  ) {
    self.enterEmailContainable = enterEmailContainable
    self.enterIdContainable = enterIdContainable
    self.viewModel = viewModel
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    attachEnterEmail()
  }
  
  // MARK: - EnterEmail
  func attachEnterEmail() {
    guard enterEmailCoordinator == nil else { return }

    let coordinater = enterEmailContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.enterEmailCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachEnterEmail() {
    guard let coordinater = enterEmailCoordinator else { return }
    
    removeChild(coordinater)
    self.enterEmailCoordinator = nil
  }
  
  // MARK: - EnterId
  func attachEnterId() {
    guard enterIdCoordinator == nil else { return }

    let coordinater = enterIdContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.enterIdCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachEnterId() {
    guard let coordinater = enterIdCoordinator else { return }
    
    navigationController?.popViewController(animated: true)
    removeChild(coordinater)
    self.enterIdCoordinator = nil
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
    detachEnterId()
  }
  
  func didFinishAtEnterId() {
    print(#function)
  }
}
