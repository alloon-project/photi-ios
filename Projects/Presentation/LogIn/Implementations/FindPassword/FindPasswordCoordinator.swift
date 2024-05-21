//
//  FindPasswordCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import LogIn

protocol FindPasswordViewModelable { }

// 부모 Coordinator에게 알리고 싶을 때 사용합니다.
protocol FindPasswordListener: AnyObject {
  func findPasswordDidFinish()
}

final class FindPasswordCoordinator: Coordinator, FindPasswordCoordinatable {
  weak var listener: FindPasswordListener?
  
  private let viewController: FindPasswordViewController
  private let viewModel: any FindPasswordViewModelType
  
  override init() {
    self.viewController = FindPasswordViewController()
    self.viewModel = FindPasswordViewModel()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}
