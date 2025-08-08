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
  func requestConvertInitialHome()
  func didJoinChallenge(challengeId: Int)
  func didCreateChallenge(challengeId: Int)
}

protocol NoneChallengeHomePresentable {
  func configureUserName(_ username: String)
}

final class NoneChallengeHomeCoordinator: ViewableCoordinator<NoneChallengeHomePresentable> {
  weak var listener: NoneChallengeHomeListener?

  private let viewModel: NoneChallengeHomeViewModel
  
  private let noneMemberChallengeContainer: NoneMemberChallengeContainable
  private var noneMemberChallengeCoordinator: ViewableCoordinating?
  
  private let challengeOrganizeContainer: ChallengeOrganizeContainable
  private var challengeOrganizeCoordinator: Coordinating?
  private var challengeOrganizeNavigation: NavigationControllerable?

  init(
    viewControllerable: ViewControllerable,
    viewModel: NoneChallengeHomeViewModel,
    noneMemberChallengeContainer: NoneMemberChallengeContainable,
    challengeOrganizeContainer: ChallengeOrganizeContainable
  ) {
    self.viewModel = viewModel
    self.noneMemberChallengeContainer = noneMemberChallengeContainer
    self.challengeOrganizeContainer = challengeOrganizeContainer
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
  
  func attachChallengeOrganize() {
    guard challengeOrganizeCoordinator == nil else { return }
    
    let navigation = NavigationControllerable()
    let coordinater = challengeOrganizeContainer.coordinator(navigationControllerable: navigation, listener: self)
    viewControllerable.present(
      navigation,
      animated: true,
      modalPresentationStyle: .overFullScreen
    )
    addChild(coordinater)
    challengeOrganizeNavigation = navigation
    challengeOrganizeCoordinator = coordinater
  }
  
  func detachChallengeOrganize(animated: Bool) {
    guard let coordinater = challengeOrganizeCoordinator else { return }
    challengeOrganizeNavigation?.dismiss(animated: animated)
    removeChild(coordinater)
    
    challengeOrganizeNavigation = nil
    challengeOrganizeCoordinator = nil
  }
}

// MARK: - NoneMemberChallengeListener
extension NoneChallengeHomeCoordinator: NoneMemberChallengeListener {
  func didTapBackButtonAtNoneMemberChallenge() {
    detachNoneMemberChallenge()
  }
  
  func alreadyJoinedChallenge(id: Int) {
    listener?.requestConvertInitialHome()
  }
  
  func didJoinChallenge(id: Int) {
    listener?.didJoinChallenge(challengeId: id)
  }
  
  func authenticatedFailedAtNoneMemberChallenge() {
    listener?.authenticatedFailedAtNoneChallengeHome()
  }
  
  func shouldDismissNoneMemberChallenge() {
    detachNoneMemberChallenge()
  }
}

// MARK: - ChallengeOrganizeListener
extension NoneChallengeHomeCoordinator: ChallengeOrganizeListener {
  func didTapBackButtonAtChallengeOrganize() {
    detachChallengeOrganize(animated: true)
  }
  
  func didOrganizedChallenge(challengeId: Int) {
    detachChallengeOrganize(animated: false)
    listener?.didCreateChallenge(challengeId: challengeId)
  }
}
