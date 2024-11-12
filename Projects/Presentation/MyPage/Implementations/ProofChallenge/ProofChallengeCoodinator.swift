//
//  ProofChallengeCoodinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Core

protocol ProofChallengeViewModelable { }

public protocol ProofChallengeListener: AnyObject {
  func didTapBackButtonAtProofChallenge()
}

final class ProofChallengeCoordinator: Coordinator {
  weak var listener: ProofChallengeListener?
  
  private let viewController: ProofChallengeViewController
  private let viewModel: ProofChallengeViewModel
  
  init(viewModel: ProofChallengeViewModel) {
    self.viewModel = viewModel
    self.viewController = ProofChallengeViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - Coordinatable
extension ProofChallengeCoordinator: ProofChallengeCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtProofChallenge()
  }
  
  func attachChallengeDetail() {
  }
  
  func detachChallengeDetail() {
  }
}
