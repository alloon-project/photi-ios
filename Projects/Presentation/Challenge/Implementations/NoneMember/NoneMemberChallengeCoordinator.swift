//
//  NoneMemberChallengeCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol NoneMemberChallengeListener: AnyObject { }

protocol NoneMemberChallengePresentable { }

final class NoneMemberChallengeCoordinator: ViewableCoordinator<NoneMemberChallengePresentable> {
  weak var listener: NoneMemberChallengeListener?

  private let viewModel: NoneMemberChallengeViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: NoneMemberChallengeViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - NoneMemberChallengeCoordinatable
extension NoneMemberChallengeCoordinator: NoneMemberChallengeCoordinatable { }
