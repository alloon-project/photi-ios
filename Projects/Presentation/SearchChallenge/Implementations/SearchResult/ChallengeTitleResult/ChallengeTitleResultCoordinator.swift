//
//  ChallengeTitleResultCoordinator.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator

protocol ChallengeTitleResultListener: AnyObject {
  func didTapChallengeAtChallengeTitleResult(challengeId: Int)
}

protocol ChallengeTitleResultPresentable { }

final class ChallengeTitleResultCoordinator: ViewableCoordinator<ChallengeTitleResultPresentable> {
  weak var listener: ChallengeTitleResultListener?

  private let viewModel: ChallengeTitleResultViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeTitleResultViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - ChallengeTitleResultCoordinatable
extension ChallengeTitleResultCoordinator: ChallengeTitleResultCoordinatable {
  func didTapChallenge(challengeId: Int) {
    listener?.didTapChallengeAtChallengeTitleResult(challengeId: challengeId)
  }
}
