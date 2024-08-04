//
//  SettingCoordinator.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import MyPage

protocol SettingViewModelable { }

public protocol SettingListener: AnyObject { }

final class SettingCoordinator: Coordinator, SettingCoordinatable {
  weak var listener: SettingListener?
  
  private let viewController: SettingViewController
  private let viewModel: SettingViewModel
  
  init(viewModel: SettingViewModel) {
    self.viewModel = viewModel
    self.viewController = SettingViewController()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
