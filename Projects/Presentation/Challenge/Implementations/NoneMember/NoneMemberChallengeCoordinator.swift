//
//  NoneMemberChallengeCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 1/22/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Challenge
import Core
import LogIn

@MainActor protocol NoneMemberChallengePresentable {
  func presentWelcomeToastView(_ username: String)
}

final class NoneMemberChallengeCoordinator: ViewableCoordinator<NoneMemberChallengePresentable> {
  weak var listener: NoneMemberChallengeListener?
  private let challengeId: Int
  private let viewModel: NoneMemberChallengeViewModel
  
  private let enterChallengeGoalContainer: EnterChallengeGoalContainable
  private var enterChallengeGoalCoordinator: ViewableCoordinating?
  
  private let logInGuideContainer: LogInGuideContainable
  private var logInGuideCoordinator: ViewableCoordinating?
  
  private let logInContainer: LogInContainable
  private var logInCoordinator: ViewableCoordinating?
  
  init(
    challengeId: Int,
    viewControllerable: ViewControllerable,
    viewModel: NoneMemberChallengeViewModel,
    enterChallengeGoalContainer: EnterChallengeGoalContainable,
    logInGuideContainer: LogInGuideContainable,
    logInContainer: LogInContainable
  ) {
    self.challengeId = challengeId
    self.enterChallengeGoalContainer = enterChallengeGoalContainer
    self.logInGuideContainer = logInGuideContainer
    self.logInContainer = logInContainer
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - Detach
private extension NoneMemberChallengeCoordinator {
  func detachEnterChallengeGoal() {
    guard let coordinator = enterChallengeGoalCoordinator else { return }
    
    removeChild(coordinator)
    self.enterChallengeGoalCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
  
  func detachLogInGuide(animted: Bool) {
    guard let coordinator = logInGuideCoordinator else { return }
    
    removeChild(coordinator)
    self.logInGuideCoordinator = nil
    viewControllerable.popViewController(animated: animted)
  }
  
  func detachLogIn(animted: Bool) {
    guard let coordinator = logInCoordinator else { return }
    
    removeChild(coordinator)
    self.logInCoordinator = nil
    viewControllerable.popViewController(animated: animted)
  }
}

// MARK: - NoneMemberChallengeCoordinatable
extension NoneMemberChallengeCoordinator: NoneMemberChallengeCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtNoneMemberChallenge()
  }
  
  func attachEnterChallengeGoal(challengeName: String, challengeID: Int) {
    guard enterChallengeGoalCoordinator == nil else { return }
    
    let coordinator = enterChallengeGoalContainer.coordinator(
      mode: .add,
      challengeID: challengeID,
      challengeName: challengeName,
      listener: self
    )
    
    addChild(coordinator)
    self.enterChallengeGoalCoordinator = coordinator
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
  }
  
  func attachLogInGuide() {
    guard logInGuideCoordinator == nil else { return }
    
    let coordinator = logInGuideContainer.coordinator(listener: self)
    addChild(coordinator)
    self.logInGuideCoordinator = coordinator
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
  }
  
  func attachLogIn() {
    guard logInCoordinator == nil else { return }
    
    let coordinator = logInContainer.coordinator(listener: self)
    addChild(coordinator)
    self.logInCoordinator = coordinator
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
  }
}

// MARK: - EnterChallengeGoalListener
extension NoneMemberChallengeCoordinator: EnterChallengeGoalListener {
  func didTapBackButtonAtEnterChallengeGoal() {
    detachEnterChallengeGoal()
  }
  
  func didFinishEnterChallengeGoal(_ goal: String) {
    listener?.didJoinChallenge(id: challengeId)
  }
  
  func authenticatedFailedAtEnterChallengeGoal() {
    listener?.authenticatedFailedAtNoneMemberChallenge()
  }
}

// MARK: - LogInGuideListener
extension NoneMemberChallengeCoordinator: LogInGuideListener {
  func didTapBackButtonAtLogInGuide() {
    detachLogInGuide(animted: true)
  }
  
  func didTapLogInButtonAtLogInGuide() {
    attachLogIn()
  }
}

// MARK: - LogInListener
extension NoneMemberChallengeCoordinator: LogInListener {
  func didFinishLogIn(userName: String) {
    detachLogIn(animted: false)
    detachLogInGuide(animted: true)
    Task { await presenter.presentWelcomeToastView(userName) }
  }
  
  func didTapBackButtonAtLogIn() {
    detachLogIn(animted: true)
  }
}
