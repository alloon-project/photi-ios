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

final class ChallengeOrganizeCoordinator: Coordinator {

  private var challengeName: String?
  private var isPublic: Bool = true
  private var challengeGoal: String?
  private var challengeProveTime: String?
  private var challengeEndDate: String?
  private var challengeCover: UIImageWrapper?
  private var challengeRule: [[String: String]]
  private var challengeHashtags: [[String: String]]
  
  weak var listener: ChallengeOrganizeListener?
  
  private let navigationControllerable: NavigationControllerable

  private let challengeStartContainable: ChallengeNameContainable
  private var challengeStartCoordinator: Coordinating?
  
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
    challengeStartContainable: ChallengeStartContainable,
    challengeNameContainable: ChallengeNameContainable,
    challengeGoalContainable: ChallengeGoalContainable,
    challengeCoverContainable: ChallengeCoverContainable,
    challengeRuleContainable: ChallengeRuleContainable,
    challengeHashTagContainable: ChallengeHashTagContainable,
    challengePreviewContainable: ChallengePreviewContainable
  ) {
    self.navigationControllerable = navigationControllerable
    self.challengeStartContainable = challengeStartContainable
    self.challengeNameContainable = challengeNameContainable
    self.challengeGoalContainable = challengeGoalContainable
    self.challengeCoverContainable = challengeCoverContainable
    self.challengeRuleContainable = challengeRuleContainable
    self.challengeHashTagContainable = challengeHashTagContainable
    self.challengePreviewContainable = challengePreviewContainable
    super.init()
    
  }
  
  override func start() {
    attachChallengeStart()
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
  
  // MARK: - ChallengeStart
  func attachChallengeStart() {
    guard challengeStartCoordinator == nil else { return }
    
    let coordinater = challengeStartContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.challengeStartCoordinator = coordinater
  }
  
  func detachChallengeStart(animated: Bool) {
    guard let coordinater = challengeStartCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeStartCoordinator = nil
  }
  
  // MARK: - ChallengeName
  func attachChallengeName() {
    guard challengeNameCoordinator == nil else { return }
    
    let coordinater = challengeNameContainable.coordinator(listener: self)
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
  
  // MARK: - ChallengeGoal
  func attachChallengeGoal() {
    guard challengeGoalCoordinator == nil else { return }
    
    let coordinater = challengeGoalContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.challengeCoverCoordinator = coordinater
  }
  
  func detachChallengeGoal(animated: Bool) {
    guard let coordinater = challengeGoalCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeGoalCoordinator = nil
  }
  
  // MARK: - ChallengeCover
  func attachChallengeCover() {
    guard challengeCoverCoordinator == nil else { return }
    
    let coordinater = challengeCoverContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.challengeCoverCoordinator = coordinater
  }
  
  func detachChallengeCover(animated: Bool) {
    guard let coordinater = challengeCoverCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeCoverCoordinator = nil
  }
  
  // MARK: - ChallengeRule
  func attachChallengeRule() {
    guard challengeRuleCoordinator == nil else { return }
    
    let coordinater = challengeRuleContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.challengeRuleCoordinator = coordinater
  }
  
  func detachChallengeRule(animated: Bool) {
    guard let coordinater = challengeRuleCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeRuleCoordinator = nil
  }
  
  // MARK: - ChallengeHashtag
  func attachChallengeHashtag() {
    guard challengeHashTagCoordinator == nil else { return }
    
    let coordinater = challengeHashTagContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.challengeHashTagCoordinator = coordinater
  }
  
  func detachChallengeHashTag(animated: Bool) {
    guard let coordinater = challengeHashTagCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeHashTagCoordinator = nil
  }
  
  // MARK: - ChallengePreview
  func attachChallengePreview() {
    guard challengePreviewCoordinator == nil else { return }
    
    let coordinater = challengePreviewContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.challengePreviewCoordinator = coordinater
  }
  
  func detachChallengePreview(animated: Bool) {
    guard let coordinater = challengePreviewCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengePreviewCoordinator = nil
  }
}

// MARK: ChallengeStartListener
extension ChallengeOrganizeCoordinator: ChallengeStartListener {
  
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
