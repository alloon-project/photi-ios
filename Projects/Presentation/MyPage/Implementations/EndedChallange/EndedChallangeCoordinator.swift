//
//  EndedChallengeCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol EndedChallengeViewModelable { }

public protocol EndedChallengeListener: AnyObject {
  func didTapBackButtonAtEndedChallenge()
}

final class EndedChallengeCoordinator: Coordinator {
  weak var listener: EndedChallengeListener?
  
  private let viewController: EndedChallengeViewController
  private let viewModel: EndedChallengeViewModel
  
  init(
    viewModel: EndedChallengeViewModel
  ) {
    self.viewModel = viewModel
    self.viewController = EndedChallengeViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - Coordinatable
extension EndedChallengeCoordinator: EndedChallengeCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEndedChallenge()
  }
  
  func attachChallengeDetail() {
  }
  
  func detachChallengeDetail() {
  }
}
