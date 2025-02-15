//
//  ProofChallengeCoodinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol ProofChallengeListener: AnyObject {
  func didTapBackButtonAtProofChallenge()
}

protocol ProofChallengePresentable { }

final class ProofChallengeCoordinator: ViewableCoordinator<ProofChallengePresentable> {
  weak var listener: ProofChallengeListener?
  
  private let viewModel: ProofChallengeViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ProofChallengeViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - ProofChallengeCoordinatable
extension ProofChallengeCoordinator: ProofChallengeCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtProofChallenge()
  }
  
  func attachChallengeDetail() { }
  
  func detachChallengeDetail() { }
}
