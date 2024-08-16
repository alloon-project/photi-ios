//
//  SettingCoordinator.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol SettingViewModelable { }

public protocol SettingListener: AnyObject { }

final class SettingCoordinator: Coordinator, SettingCoordinatable {
  weak var listener: SettingListener?
  
  private let viewController: SettingViewController
  private let viewModel: SettingViewModel
  
  private let profileEditContainable: ProfileEditContainable
  private var profileEditCoordinator: Coordinating?
  
  init(
    viewModel: SettingViewModel,
    profileEditContainable: ProfileEditContainable
  ) {
    self.viewModel = viewModel
    
    self.profileEditContainable = profileEditContainable
    self.viewController = SettingViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  func attachProfileEdit() {
    guard profileEditCoordinator == nil else { return }
    
    let coordinater = profileEditContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.profileEditCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachProfileEdit() {
    guard let coordinator = profileEditCoordinator else { return }
    
    removeChild(coordinator)
    self.profileEditCoordinator = nil
  }
  
  func attachInquiry() {}
  
  func detachInquiry() {}
  
  func attachServiceTerms() {}
  
  func detachServiceTerms() {}
  
  func attachPrivacy() {}
  
  func detachPrivacy() {}
}

// MARK: - ProfileEditListener
extension SettingCoordinator: ProfileEditListener {}
