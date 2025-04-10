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

protocol NoneMemberChallengePresentable { }

final class NoneMemberChallengeCoordinator: ViewableCoordinator<NoneMemberChallengePresentable> {
  weak var listener: NoneMemberChallengeListener?

  private let viewModel: NoneMemberChallengeViewModel
  
  private let enterChallengeGoalContainer: EnterChallengeGoalContainable
  private var enterChallengeGoalCoordinator: ViewableCoordinating?
  
  private let logInGuideContainer: LogInGuideContainable
  private var logInGuideCoordinator: ViewableCoordinating?
  
  private let logInContainer: LogInContainable
  private var logInCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: NoneMemberChallengeViewModel,
    enterChallengeGoalContainer: EnterChallengeGoalContainable,
    logInGuideContainer: LogInGuideContainable,
    logInContainer: LogInContainable
  ) {
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
  
  func detachLogInGuide() {
    guard let coordinator = logInGuideCoordinator else { return }
    
    removeChild(coordinator)
    self.logInGuideCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
  
  func detachLogIn() {
    guard let coordinator = logInCoordinator else { return }
    
    removeChild(coordinator)
    self.logInCoordinator = nil
    viewControllerable.popViewController(animated: true)
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
    detachEnterChallengeGoal()
    listener?.didJoinChallenge()
  }
  
  func requestLoginAtEnterChallengeGoal() {
    attachLogIn()
  }
}

// MARK: - LogInGuideListener
extension NoneMemberChallengeCoordinator: LogInGuideListener {
  func didTapBackButtonAtLogInGuide() {
    detachLogInGuide()
  }
  
  func didTapLogInButtonAtLogInGuide() {
    attachLogIn()
  }
}

// MARK: - LogInListener
extension NoneMemberChallengeCoordinator: LogInListener {
  func didFinishLogIn(userName: String) {
    detachLogIn()
    detachLogInGuide()
  }
  
  func didTapBackButtonAtLogIn() {
    detachLogIn()
  }
}
