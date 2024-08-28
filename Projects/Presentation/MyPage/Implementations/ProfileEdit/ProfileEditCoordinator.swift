//
//  ProfileEditCoordinator.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol ProfileEditViewModelable { }

public protocol ProfileEditListener: AnyObject { 
  func didTapBackButtonAtProfileEdit()
}

final class ProfileEditCoordinator: Coordinator {
  weak var listener: ProfileEditListener?
  
  private let viewController: ProfileEditViewController
  private let viewModel: ProfileEditViewModel
  
  private let passwordChangeContainable: PasswordChangeContainable
  private var passwordCoordinator: Coordinating?
  
  init(
    viewModel: ProfileEditViewModel,
    passwordChangeContainable: PasswordChangeContainable
  ) {
    self.viewModel = viewModel
    
    self.passwordChangeContainable = passwordChangeContainable
    self.viewController = ProfileEditViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  // MARK: - ChangePassword
  func attachChangePassword() {
    guard passwordCoordinator == nil else { return }
    
    let coordinater = passwordChangeContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.passwordCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
}

// MARK: - Coordinatable
extension ProfileEditCoordinator: ProfileEditCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtProfileEdit()
  }
}

// MARK: - PasswordChangeLister
extension ProfileEditCoordinator: PasswordChangeListener {}
