//
//  ChallengeHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeHomeListener: AnyObject { }

protocol ChallengeHomePresentable { }

final class ChallengeHomeCoordinator: ViewableCoordinator<ChallengeHomePresentable> {
  weak var listener: ChallengeHomeListener?

  private let viewModel: ChallengeHomeViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeHomeViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - Coordinatable
extension ChallengeHomeCoordinator: ChallengeHomeCoordinatable {
  func attachLogin() { }
}
