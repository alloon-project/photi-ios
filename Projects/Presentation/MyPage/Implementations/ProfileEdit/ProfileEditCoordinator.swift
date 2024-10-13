//
//  ProfileEditCoordinator.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import MyPage
import Core

protocol ProfileEditViewModelable { }

final class ProfileEditCoordinator: Coordinator {
  weak var listener: ProfileEditListener?
  
  private let viewController: ProfileEditViewController
  private let viewModel: ProfileEditViewModel
  
  private let passwordChangeContainable: PasswordChangeContainable
  private var passwordCoordinator: Coordinating?

  private let resignContainable: ResignContainable
  private var resignCoordinator: Coordinating?
  
  init(
    viewModel: ProfileEditViewModel,
    passwordChangeContainable: PasswordChangeContainable,
    resignContainable: ResignContainable
  ) {
    self.viewModel = viewModel
    
    self.passwordChangeContainable = passwordChangeContainable
    self.resignContainable = resignContainable
    
    self.viewController = ProfileEditViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - Coordinatable
extension ProfileEditCoordinator: ProfileEditCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtProfileEdit()
  }
  
  func attachChangePassword() {
    guard passwordCoordinator == nil else { return }
    
    let coordinater = passwordChangeContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.passwordCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func attachResign() {
    guard resignCoordinator == nil else { return }
    
    let coordinater = resignContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.resignCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachResign() {
    guard let coordinater = resignCoordinator else { return }
    
    removeChild(coordinater)
    self.resignCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - PasswordChangeLister
extension ProfileEditCoordinator: PasswordChangeListener {}

// MARK: - ResignLisenter
extension ProfileEditCoordinator: ResignListener {
  func didTapBackButtonAtResign() {
    detachResign()
  }
  
  func didTapCancelButtonAtResign() {
    detachResign()
  }
}
