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
  func authenticatedFailedAtNoneChallengeHome()
  func requstConvertInitialHome()
}

protocol NoneChallengeHomePresentable {
  func configureUserName(_ username: String)
}

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
  
  override func start() {
    presenter.configureUserName(ServiceConfiguration.shared.userName)
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
    viewControllerable.uiviewController.showTabBar(animted: true)
    noneMemberChallengeCoordinator = nil
  }
}

// MARK: - NoneMemberChallenge
extension NoneChallengeHomeCoordinator: NoneMemberChallengeListener {
  func didTapBackButtonAtNoneMemberChallenge() {
    detachNoneMemberChallenge()
  }
  
  func didJoinChallenge(id: Int) {
    listener?.requstConvertInitialHome()
  }
  
  func authenticatedFailedAtNoneMemberChallenge() {
    listener?.authenticatedFailedAtNoneChallengeHome()
  }
  
  func shouldDismissNoneMemberChallenge() {
    detachNoneMemberChallenge()
  }
}
