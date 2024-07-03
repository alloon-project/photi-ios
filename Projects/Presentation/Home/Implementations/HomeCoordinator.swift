//
//  HomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import Home

protocol HomeViewModelable { }

final class HomeCoordinator: Coordinator, HomeCoordinatable {
  weak var listener: HomeListener?
  
  private let viewController: HomeViewController
  private let viewModel: HomeViewModel
  
  init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    self.viewController = HomeViewController()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
