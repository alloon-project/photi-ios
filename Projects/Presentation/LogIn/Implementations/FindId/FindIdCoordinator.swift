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

protocol FindIdViewModelable {
  // Coordinator에서 ViewModel로 전달할 이벤트입니다.
}

protocol FindIdListener: AnyObject {
  // 부모 Coordinator에게 알릴 이벤트를 정의합니다 ex) func didFinishFindId()
}

final class FindIdCoordinator: Coordinator, FindIdCoordinatable {
  weak var listener: FindIdListener?
  
  private let viewController: FindIdViewController
  private let viewModel: any FindIdViewModelType
  
  override init() {
    self.viewController = FindIdViewController()
    self.viewModel = FindIdViewModel()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}