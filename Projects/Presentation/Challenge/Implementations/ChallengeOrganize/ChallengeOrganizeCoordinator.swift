//
//  ChallengeOrganizeCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeOrganizeListener: AnyObject {
  func didTapBackButtonAtChallengeOrganize()
  func didTapBackButtonAtChallenge()
}

protocol ChallengeOrganizePresentable { }

final class ChallengeOrganizeCoordinator: ViewableCoordinator<ChallengeOrganizePresentable>, ChallengeOrganizeCoordinatable {

  
  weak var listener: ChallengeOrganizeListener?
  
  private let navigationControllerable: NavigationControllerable

  private let viewModel: any ChallengeOrganizeViewModelType
  
  private let challengeNameContainable: ChallengeNameContainable
  private var challengeNameCoordinator: Coordinating?

  private let challengeGoalContainable: ChallengeGoalContainable
  private var challengeGoalCoordinator: Coordinating?
  
  private let challengeCoverContainable: ChallengeCoverContainable
  private var challengeCoverCoordinator: Coordinating?
  
  private let challengeRuleContainable: ChallengeRuleContainable
  private var challengeRuleCoordinator: Coordinating?
  
  private let challengeHashTagContainable: ChallengeHashTagContainable
  private var challengeHashTagCoordinator: Coordinating?
  
  private let challengePreviewContainable: ChallengePreviewContainable
  private var challengePreviewCoordinator: Coordinating?
  
  
  init(
    navigationControllerable: NavigationControllerable,
    viewModel: ChallengeOrganizeViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtChallengeOrganize()
  }
  
  override func stop() {
    detachChallengePreview(animated: false)
    detachChallengeHashTag(animated: false)
    detachChallengeRule(animated: false)
    detachChallengeCover(animated: false)
    detachChallengeGoal(animated: false)
    detachChallengeName(animated: false)
    self.navigationControllerable.popViewController(animated: false)
  }
  
  func attachChallengeName() {
    guard challengeNameCoordinator == nil else { return }
    
    let coordinater = challengeNameContainable.coordinator()
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.challengeNameCoordinator = coordinater
  }
  
  func detachChallengeName(animated: Bool) {
    guard let coordinater = challengeNameCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeNameCoordinator = nil
  }
  
  func detachChallengeGoal(animated: Bool) {
    guard let coordinater = challengeGoalCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeGoalCoordinator = nil
  }
  
  func detachChallengeCover(animated: Bool) {
    guard let coordinater = challengeCoverCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeCoverCoordinator = nil
  }
  
  func detachChallengeRule(animated: Bool) {
    guard let coordinater = challengeRuleCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeRuleCoordinator = nil
  }
  
  func detachChallengeHashTag(animated: Bool) {
    guard let coordinater = challengeHashTagCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeHashTagCoordinator = nil
  }
  
  func detachChallengePreview(animated: Bool) {
    guard let coordinater = challengePreviewCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengePreviewCoordinator = nil
  }
}

// MARK: ChallengeNameListener
extension ChallengeOrganizeCoordinator: ChallengeNameListener  {
  
}

// MARK: ChallengeGoalListener
extension ChallengeOrganizeCoordinator: ChallengeGoalListener  {

}

// MARK: ChallengeCoverListener
extension ChallengeOrganizeCoordinator: ChallengeCoverListener  {

}

// MARK: ChallengeRuleListener
extension ChallengeOrganizeCoordinator: ChallengeRuleListener  {

}

// MARK: ChallengeHashTagListener
extension ChallengeOrganizeCoordinator: ChallengeHashTagListener  {

}

// MARK: ChallengePreviewListener
extension ChallengeOrganizeCoordinator: ChallengePreviewListener  {

}
