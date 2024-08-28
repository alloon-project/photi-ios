//
//  AuthCountDetailCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 8/26/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol AuthCountDetailViewModelable { }

public protocol AuthCountDetailListener: AnyObject { }

final class AuthCountDetailCoordinator: Coordinator, AuthCountDetailCoordinatable {
  weak var listener: AuthCountDetailListener?
  
  private let viewController: AuthCountDetailViewController
  private let viewModel: AuthCountDetailViewModel
  
  init(viewModel: AuthCountDetailViewModel) {
    self.viewModel = viewModel
    self.viewController = AuthCountDetailViewController()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
