//
//  EnterEmailCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator

protocol EnterEmailListener: AnyObject {
  func didTapBackButtonAtEnterEmail()
  func didFinishEnterEmail()
}

protocol EnterEmailPresentable { }

final class EnterEmailCoordinator: ViewableCoordinator<EnterEmailPresentable> {
  private var email: String?
  
  weak var listener: EnterEmailListener?
  
  private let viewModel: EnterEmailViewModel
  
  private let verifyEmailContainable: VerifyEmailContainable
  private var verifyEmailCoordinator: Coordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: EnterEmailViewModel,
    verifyEmailContainable: VerifyEmailContainable
  ) {
    self.viewModel = viewModel
    self.verifyEmailContainable = verifyEmailContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func stop() {
    Task { await detachVerifyEmail() }
  }
}

// MARK: - VerifyEmail
@MainActor extension EnterEmailCoordinator {
  func attachVerifyEmail(userEmail: String) {
    guard verifyEmailCoordinator == nil else { return }
    
    let coordinater = verifyEmailContainable.coordinator(listener: self, userEmail: userEmail)
    addChild(coordinater)
    
    self.email = userEmail
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: false)
    self.verifyEmailCoordinator = coordinater
  }
  
  func detachVerifyEmail() {
    guard let coordinater = verifyEmailCoordinator else { return }
    
    removeChild(coordinater)
    viewControllerable.popViewController(animated: false)
    self.verifyEmailCoordinator = nil
  }
}

// MARK: - EnterEmailCoordinatable
extension EnterEmailCoordinator: EnterEmailCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEnterEmail()
  }
}

// MARK: - VerifyEmailListener
extension EnterEmailCoordinator: VerifyEmailListener {
  func didTapBackButtonAtVerifyEmail() {
    Task { await detachVerifyEmail() }
  }
  
  func didFinishVerifyEmail(with verificationCode: String) {
    guard email != nil else { return }
    
    listener?.didFinishEnterEmail()
  }
}
