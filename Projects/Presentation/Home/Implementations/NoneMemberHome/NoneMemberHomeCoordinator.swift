//
//  NoneMemberHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 9/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol NoneMemberHomeViewModelable: AnyObject { }

protocol NoneMemberHomeListener: AnyObject { }

final class NoneMemberHomeCoordinator: Coordinator, NoneMemberHomeCoordinatable {
  weak var listener: NoneMemberHomeListener?
  
  private let viewController: NoneMemberHomeViewController
  private let viewModel: NoneMemberHomeViewModel
  
  init(viewModel: NoneMemberHomeViewModel) {
    self.viewModel = viewModel
    self.viewController = NoneMemberHomeViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}
