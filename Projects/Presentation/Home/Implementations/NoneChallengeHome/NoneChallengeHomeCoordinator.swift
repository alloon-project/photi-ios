//
//  NoneChallengeHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Challenge
import Core

protocol NoneChallengeHomeListener: AnyObject {
  func requestLoginAtNoneChallengeHome()
  func requstConvertInitialHome()
}

protocol NoneChallengeHomePresentable { }

final class NoneChallengeHomeCoordinator: ViewableCoordinator<NoneChallengeHomePresentable> {
  weak var listener: NoneChallengeHomeListener?

  private let viewModel: NoneChallengeHomeViewModel
  
  private let noneMemberChallengeContainer: NoneMemberChallengeContainable
  private var noneMemberChallengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: NoneChallengeHomeViewModel,
    noneMemberChallengeContainer: NoneMemberChallengeContainable
  ) {
    self.viewModel = viewModel
    self.noneMemberChallengeContainer = noneMemberChallengeContainer
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - NoneMemberHomeCoordinatable
extension NoneChallengeHomeCoordinator: NoneChallengeHomeCoordinatable {
  func attachNoneMemberChallenge(challengeId: Int) {
    guard noneMemberChallengeCoordinator == nil else { return }
    
    let coordinator = noneMemberChallengeContainer.coordinator(listener: self, challengeId: challengeId)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    
    self.noneMemberChallengeCoordinator = coordinator
  }
  
  func detachNoneMemberChallenge() {
    guard let coordinator = noneMemberChallengeCoordinator else { return }
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    noneMemberChallengeCoordinator = nil
  }
}

// MARK: - NoneMem
extension NoneChallengeHomeCoordinator: NoneMemberChallengeListener {
  func didTapBackButtonAtNoneMemberChallenge() {
    detachNoneMemberChallenge()
  }
  
  func didJoinChallenge() {
    detachNoneMemberChallenge()
    listener?.requstConvertInitialHome()
  }
  
  func requestLogInAtNoneMemberChallenge() {
    listener?.requestLoginAtNoneChallengeHome()
  }
}
