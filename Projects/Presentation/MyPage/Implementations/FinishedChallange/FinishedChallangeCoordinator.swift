//
//  FinishedChallengeCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol FinishedChallengeViewModelable { }

public protocol FinishedChallengeListener: AnyObject {
  func didTapBackButtonAtFinishedChallenge()
}

final class FinishedChallengeCoordinator: Coordinator {
  weak var listener: FinishedChallengeListener?
  
  private let viewController: FinishedChallengeViewController
  private let viewModel: FinishedChallengeViewModel
  
  init(
    viewModel: FinishedChallengeViewModel
  ) {
    self.viewModel = viewModel
    self.viewController = FinishedChallengeViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - Coordinatable
extension FinishedChallengeCoordinator: FinishedChallengeCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtFinishedChallenge()
  }
  
  func attachChallengeDetail() {
  }
  
  func detachChallengeDetail() {
  }
}
