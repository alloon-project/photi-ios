//
//  MyPageCoordinator.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import MyPage

protocol MyPageViewModelable { }

final class MyPageCoordinator: Coordinator, MyPageCoordinatable {
  weak var listener: MyPageListener?
  
  private let viewController: MyPageViewController
  private let viewModel: MyPageViewModel
  
  private let settingContainable: SettingContainable
  private var settingCoordinator: Coordinating?
  
  private let authCountDetailContainable: AuthCountDetailContainable
  private var authCountDetailCoordinator: Coordinating?
  
  init(
    viewModel: MyPageViewModel,
    settingContainable: SettingContainable,
    authCountDetailContainable: AuthCountDetailContainable
  ) {
    self.viewModel = viewModel
    
    self.settingContainable = settingContainable
    self.authCountDetailContainable = authCountDetailContainable
    self.viewController = MyPageViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.setNavigationBarHidden(true, animated: false)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  func attachSetting() {
    guard settingCoordinator == nil else { return }
    
    let coordinater = settingContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.settingCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachSetting() {
    guard let coordinator = settingCoordinator else { return }
    
    removeChild(coordinator)
    self.settingCoordinator = nil
  }
  
  func attachAuthCountDetail() {
    guard authCountDetailCoordinator == nil else { return }
    
    let coordinater = authCountDetailContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.authCountDetailCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachAuthCountDetail() {
    guard let coordinator = authCountDetailCoordinator else { return }
    
    removeChild(coordinator)
    self.authCountDetailCoordinator = nil
  }
}

// MARK: - SettingListener
extension MyPageCoordinator: SettingListener {}

// MARK: - AuthCountDetailListener
extension MyPageCoordinator: AuthCountDetailListener {}
