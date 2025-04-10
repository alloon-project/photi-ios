//
//  NoneChallengeHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core

protocol NoneChallengeHomeListener: AnyObject { }

protocol NoneChallengeHomePresentable {
  func configureUserName(_ username: String)
}

final class NoneChallengeHomeCoordinator: ViewableCoordinator<NoneChallengeHomePresentable> {
  weak var listener: NoneChallengeHomeListener?

  private let viewModel: NoneChallengeHomeViewModel
  
  private let noneMemberChallengeContainable: NoneMemberChallengeContainable
  private var noneMemberChallengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: NoneChallengeHomeViewModel,
    noneMemberChallengeContainable: NoneMemberChallengeContainable
  ) {
    self.viewModel = viewModel
    self.noneMemberChallengeContainable = noneMemberChallengeContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    presenter.configureUserName(ServiceConfiguration.shared.userName)
  }
}

// MARK: - NoneMemberHomeCoordinatable
extension NoneChallengeHomeCoordinator: NoneChallengeHomeCoordinatable { }
