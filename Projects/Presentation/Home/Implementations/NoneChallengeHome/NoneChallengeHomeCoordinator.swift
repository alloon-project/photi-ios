//
//  NoneChallengeHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol NoneChallengeHomeViewModelable: AnyObject { }

protocol NoneChallengeHomeListener: AnyObject { }

final class NoneChallengeHomeCoordinator: Coordinator {
  weak var listener: NoneChallengeHomeListener?
  
  private let viewController: NoneChallengeHomeViewController
  private let viewModel: NoneChallengeHomeViewModel
  
  init(viewModel: NoneChallengeHomeViewModel) {
    self.viewModel = viewModel
    self.viewController = NoneChallengeHomeViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}

// MARK: - NoneMemberHomeCoordinatable
extension NoneChallengeHomeCoordinator: NoneChallengeHomeCoordinatable { }
