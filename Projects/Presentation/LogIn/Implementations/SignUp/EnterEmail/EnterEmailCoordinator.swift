//
//  EnterEmailCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol EnterEmailListener: AnyObject {
  func didTapBackButtonAtEnterEmail()
  func didFinishEnterEmail(email: String, verificationCode: String)
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
    detachVerifyEmail(animated: false)
  }
  
  // MARK: - VerifyEmail
  func attachVerifyEmail(userEmail: String) {
    guard verifyEmailCoordinator == nil else { return }
    
    let coordinater = verifyEmailContainable.coordinator(listener: self, userEmail: userEmail)
    addChild(coordinater)
    
    self.email = userEmail
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.verifyEmailCoordinator = coordinater
  }
  
  func detachVerifyEmail(animated: Bool) {
    guard let coordinater = verifyEmailCoordinator else { return }
    
    removeChild(coordinater)
    viewControllerable.popViewController(animated: animated)
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
    detachVerifyEmail(animated: true)
  }
  
  func didFinishVerifyEmail(with verificationCode: String) {
    guard let email else { return }
    
    listener?.didFinishEnterEmail(email: email, verificationCode: verificationCode)
  }
}
