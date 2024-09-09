//
//  EnterEmailCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol EnterEmailViewModelable { }

protocol EnterEmailListener: AnyObject {
  func didTapBackButtonAtEnterEmail()
  func didFinishEnterEmail(email: String, verificationCode: String)
}

final class EnterEmailCoordinator: Coordinator, EnterEmailCoordinatable {
  private var email: String?
  
  weak var listener: EnterEmailListener?
  
  private let viewController: EnterEmailViewController
  private let viewModel: EnterEmailViewModel
  
  private let verifyEmailContainable: VerifyEmailContainable
  private var verifyEmailCoordinator: Coordinating?
  
  init(
    viewModel: EnterEmailViewModel,
    verifyEmailContainable: VerifyEmailContainable
  ) {
    self.verifyEmailContainable = verifyEmailContainable
    self.viewModel = viewModel
    self.viewController = EnterEmailViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
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
    self.verifyEmailCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachVerifyEmail(animated: Bool) {
    guard let coordinater = verifyEmailCoordinator else { return }
    
    removeChild(coordinater)
    self.verifyEmailCoordinator = nil
    navigationController?.popViewController(animated: animated)
  }
  
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
