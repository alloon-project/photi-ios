//
//  EndedChallengeCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol EndedChallengeListener: AnyObject {
  func didTapBackButtonAtEndedChallenge()
}

protocol EndedChallangePresentable { }

final class EndedChallengeCoordinator: ViewableCoordinator<EndedChallangePresentable> {
  weak var listener: EndedChallengeListener?
  
  private let viewModel: EndedChallengeViewModel
  
  init(
    viewControllerable: ViewControllable,
    viewModel: EndedChallengeViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - EndedChallengeCoordinatable
extension EndedChallengeCoordinator: EndedChallengeCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEndedChallenge()
  }
  
  func attachChallengeDetail() { }
  
  func detachChallengeDetail() { }
}
