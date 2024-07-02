//
//  MyMissionCoordinator.swift
//  MyMissionImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import MyMission

protocol MyMissionViewModelable { }

final class MyMissionCoordinator: Coordinator, MyMissionCoordinatable {
  weak var listener: MyMissionListener?
  
  private let viewController: MyMissionViewController
  private let viewModel: MyMissionViewModel
  
  init(viewModel: MyMissionViewModel) {
    self.viewModel = viewModel
    self.viewController = MyMissionViewController()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
