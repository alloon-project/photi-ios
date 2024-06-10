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
  func didFinishEnterEmail()
}

final class EnterEmailCoordinator: Coordinator, EnterEmailCoordinatable {
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
    self.viewModel = EnterEmailViewModel()
    self.viewController = EnterEmailViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  override func stop() {
    super.stop()
    detachVerifyEmail(animated: false)
  }
  
  // MARK: - VerifyEmail
  func attachVerifyEmail(userEmail: String) {
    guard verifyEmailCoordinator == nil else { return }
    
    let coordinater = verifyEmailContainable.coordinator(listener: self, userEmail: userEmail)
    addChild(coordinater)
    
    self.verifyEmailCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachVerifyEmail(animated: Bool) {
    guard let coordinater = verifyEmailCoordinator else { return }
    
    self.verifyEmailCoordinator = nil
    navigationController?.popViewController(animated: animated)
    removeChild(coordinater)
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
  
  func didFinishVerifyEmail() {
    listener?.didFinishEnterEmail()
  }
}
