//
//  NoneChallengeHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol NoneChallengeHomeListener: AnyObject { }

protocol NoneChallengeHomePresentable { }

final class NoneChallengeHomeCoordinator: ViewableCoordinator<NoneChallengeHomePresentable> {
  weak var listener: NoneChallengeHomeListener?

  private let viewModel: NoneChallengeHomeViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: NoneChallengeHomeViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - NoneMemberHomeCoordinatable
extension NoneChallengeHomeCoordinator: NoneChallengeHomeCoordinatable { }
