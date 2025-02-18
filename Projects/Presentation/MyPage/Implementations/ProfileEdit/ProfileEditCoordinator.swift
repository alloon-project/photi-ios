//
//  ProfileEditCoordinator.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol ProfileEditListener: AnyObject {
  func didTapBackButtonAtProfileEdit()
  func isUserResigned()
}

protocol ProfileEditPresentable {
  func displayToastView()
}

final class ProfileEditCoordinator: ViewableCoordinator<ProfileEditPresentable> {
  weak var listener: ProfileEditListener?
  
  private let viewModel: ProfileEditViewModel
  
  private let changePasswordContainable: ChangePasswordContainable
  private var changePasswordCoordinator: Coordinating?
  
  private let resignContainable: ResignContainable
  private var resignCoordinator: Coordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ProfileEditViewModel,
    changePasswordContainable: ChangePasswordContainable,
    resignContainable: ResignContainable
  ) {
    self.viewModel = viewModel
    
    self.changePasswordContainable = changePasswordContainable
    self.resignContainable = resignContainable
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - ProfileEditCoordinatable
extension ProfileEditCoordinator: ProfileEditCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtProfileEdit()
  }
  
  func attachChangePassword() {
    guard changePasswordCoordinator == nil else { return }
    
    let coordinator = changePasswordContainable.coordinator(listener: self)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.changePasswordCoordinator = coordinator
  }
  
  func detachChangePassword() {
    guard let coordinator = changePasswordCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.resignCoordinator = nil
  }
  
  func attachResign() {
    guard resignCoordinator == nil else { return }
    
    let coordinator = resignContainable.coordinator(listener: self)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.resignCoordinator = coordinator
  }
  
  func detachResign() {
    guard let coordinator = resignCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.resignCoordinator = nil
  }
}

// MARK: - ChangePasswordListener
extension ProfileEditCoordinator: ChangePasswordListener {
  func didTapBackButtonAtChangePassword() {
    detachChangePassword()
  }
  
  func didChangedPassword() {
    detachChangePassword()
    presenter.displayToastView()
  }
}

// MARK: - ResignLisenter
extension ProfileEditCoordinator: ResignListener {
  func didFisishedResign() {
    listener?.isUserResigned()
  }
  
  func didTapBackButtonAtResign() {
    detachResign()
  }
  
  func didTapCancelButtonAtResign() {
    detachResign()
  }
}
