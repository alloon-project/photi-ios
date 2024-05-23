//
//  EnterEmailCoordinator.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol EnterEmailViewModelable { }

protocol EnterEmailListener: AnyObject { }

final class EnterEmailCoordinator: Coordinator, EnterEmailCoordinatable {
  weak var listener: EnterEmailListener?
  
  private let viewController: EnterEmailViewController
  private let viewModel: EnterEmailViewModel
  
  init(viewModel: EnterEmailViewModel) {
    self.viewModel = EnterEmailViewModel()
    self.viewController = EnterEmailViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  func didTapBackButton() {
    listener?.enterEmailDidTapBackButton()
  }
}
