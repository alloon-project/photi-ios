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
  
  init(
    viewModel: MyPageViewModel,
    settingContainable: SettingContainable
  ) {
    self.viewModel = viewModel
    
    self.settingContainable = settingContainable
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
}

// MARK: - SettingListener
extension MyPageCoordinator: SettingListener {}
