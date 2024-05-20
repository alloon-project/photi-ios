//
//  FindIdCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import LogIn

protocol FindIdViewModelable { }

protocol FindIdListener: AnyObject { }

final class FindIdCoordinator: Coordinator, FindIdCoordinatable {
  weak var listener: FindIdListener?
  
  private let viewController: FindIdViewController
  private let viewModel: any FindIdViewModelType
  
  override init() {
    self.viewController = FindIdViewController()
    self.viewModel = FindIdViewModel()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}
