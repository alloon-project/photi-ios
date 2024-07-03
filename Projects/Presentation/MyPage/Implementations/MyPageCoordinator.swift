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
  
  init(viewModel: MyPageViewModel) {
    self.viewModel = viewModel
    self.viewController = MyPageViewController()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
