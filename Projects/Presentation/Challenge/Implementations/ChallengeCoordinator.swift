//
//  ChallengeCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core
import Challenge

protocol ChallengeViewModelable { }

final class ChallengeCoordinator: Coordinator, ChallengeCoordinatable {
  weak var listener: ChallengeListener?
  
  private let viewController: ChallengeViewController
  private let viewModel: ChallengeViewModel
  
  init(viewModel: ChallengeViewModel) {
    self.viewModel = viewModel
    self.viewController = ChallengeViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(self.viewController, animated: true)
  }
}
