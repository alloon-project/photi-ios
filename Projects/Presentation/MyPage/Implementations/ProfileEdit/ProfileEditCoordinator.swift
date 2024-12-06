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
  
  private let changePasswordContainable: ChangePasswordContainable
  private var changePasswordCoordinator: Coordinating?
  
  private let resignContainable: ResignContainable
  private var resignCoordinator: Coordinating?
  
  init(
    viewModel: ProfileEditViewModel,
    changePasswordContainable: ChangePasswordContainable,
    resignContainable: ResignContainable
  ) {
    self.viewModel = viewModel
    
    self.changePasswordContainable = changePasswordContainable
    self.resignContainable = resignContainable
    
    self.viewController = ProfileEditViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  func attachChangePassword() {
    guard changePasswordCoordinator == nil else { return }
    
    let coordinater = changePasswordContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.changePasswordCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachChangePassword() {
    guard let coordinater = changePasswordCoordinator else { return }
    
    removeChild(coordinater)
    self.resignCoordinator = nil
    navigationController?.popViewController(animated: true)
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

// MARK: - Coordinatable
extension ProfileEditCoordinator: ProfileEditCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtProfileEdit()
  }
}

// MARK: - ChangePasswordListener
extension ProfileEditCoordinator: ChangePasswordListener {
  func didTapBackButtonAtChangePassword() {
    detachChangePassword()
  }
  
  func didChangedPassword() {
    detachChangePassword()
    viewController.displayToastView()
  }
}

// MARK: - ResignLisenter
extension ProfileEditCoordinator: ResignListener {
  func didTapBackButtonAtResign() {
    detachResign()
  }
  
  func didTapCancelButtonAtResign() {
    detachResign()
  }
}
