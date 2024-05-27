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
  
  init(
    viewModel: SignUpViewModel,
    enterEmailContainable: EnterEmailContainable
  ) {
    self.enterEmailContainable = enterEmailContainable
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
}

// MARK: - EnterEmailListener
extension SignUpCoordinator: EnterEmailListener {
  func enterEmailDidTapBackButton() {
    navigationController?.popViewController(animated: true)
    listener?.didFinishSignUp()
  }
}
