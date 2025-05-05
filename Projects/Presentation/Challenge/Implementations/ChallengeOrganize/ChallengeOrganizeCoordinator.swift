//
//  ChallengeOrganizeCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Core
import Challenge

protocol ChallengeOrganizePresentable { }

final class ChallengeOrganizeCoordinator: Coordinator {
  private var challengeName: String?
  private var isPublic: Bool = true
  private var challengeGoal: String?
  private var challengeProveTime: String?
  private var challengeEndDate: Date?
  private var challengeCover: UIImageWrapper?
  private var challengeRule: [String] = []
  private var challengeHashtags: [String] = []
  
  weak var listener: ChallengeOrganizeListener?
  
  private let navigationControllerable: NavigationControllerable

  private let challengeStartContainable: ChallengeStartContainable
  private var challengeStartCoordinator: Coordinating?
  
  private let challengeNameContainable: ChallengeNameContainable
  private var challengeNameCoordinator: Coordinating?

  private let challengeGoalContainable: ChallengeGoalContainable
  private var challengeGoalCoordinator: Coordinating?
  
  private let challengeCoverContainable: ChallengeCoverContainable
  private var challengeCoverCoordinator: Coordinating?
  
  private let challengeRuleContainable: ChallengeRuleContainable
  private var challengeRuleCoordinator: Coordinating?
  
  private let challengeHashtagContainable: ChallengeHashtagContainable
  private var challengeHashtagCoordinator: Coordinating?
  
  private let challengePreviewContainable: ChallengePreviewContainable
  private var challengePreviewCoordinator: ViewableCoordinating?
  
  init(
    navigationControllerable: NavigationControllerable,
    challengeStartContainable: ChallengeStartContainable,
    challengeNameContainable: ChallengeNameContainable,
    challengeGoalContainable: ChallengeGoalContainable,
    challengeCoverContainable: ChallengeCoverContainable,
    challengeRuleContainable: ChallengeRuleContainable,
    challengeHashtagContainable: ChallengeHashtagContainable,
    challengePreviewContainable: ChallengePreviewContainable
  ) {
    self.navigationControllerable = navigationControllerable
    self.challengeStartContainable = challengeStartContainable
    self.challengeNameContainable = challengeNameContainable
    self.challengeGoalContainable = challengeGoalContainable
    self.challengeCoverContainable = challengeCoverContainable
    self.challengeRuleContainable = challengeRuleContainable
    self.challengeHashtagContainable = challengeHashtagContainable
    self.challengePreviewContainable = challengePreviewContainable
    super.init()
  }
  
  override func start() {
    attachChallengeStart()
  }
  
  override func stop() {
    detachChallengePreview(animated: false)
    detachChallengeHashtag(animated: false)
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
    self.challengeGoalCoordinator = coordinater
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
    guard challengeHashtagCoordinator == nil else { return }
    
    let coordinater = challengeHashtagContainable.coordinator(listener: self)
    addChild(coordinater)
    
    navigationControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.challengeHashtagCoordinator = coordinater
  }
  
  func detachChallengeHashtag(animated: Bool) {
    guard let coordinater = challengeHashtagCoordinator else { return }
    
    removeChild(coordinater)
    navigationControllerable.popViewController(animated: animated)
    self.challengeHashtagCoordinator = nil
  }
  
  // MARK: - ChallengePreview
  func attachChallengePreview() {
    guard challengePreviewCoordinator == nil else { return }
    
    guard
      let title = self.challengeName,
      let verificationTime = self.challengeProveTime,
      let challengeGoal = self.challengeGoal,
      let image = challengeCover,
      let deadline = self.challengeEndDate
    else { return }
    
    let viewPresentaionModel = PreviewPresentationModel(
      title: title,
      hashtags: challengeHashtags,
      verificationTime: verificationTime,
      goal: challengeGoal,
      image: image,
      rules: challengeRule,
      deadLine: deadline.toString("yyyy. MM. dd")
    )
    let coordinater = challengePreviewContainable.coordinator(
      listener: self,
      viewPresentationModel: viewPresentaionModel
    )
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
  func didTapBackButtonAtChallengeStart() {
    detachChallengeStart(animated: true)
    listener?.didTapBackButtonAtChallengeOrganize()
  }
  
  func didFinishChallengeStart() {
    attachChallengeName()
  }
}

// MARK: ChallengeNameListener
extension ChallengeOrganizeCoordinator: ChallengeNameListener {
  func didTapBackButtonAtChallengeName() {
    detachChallengeName(animated: true)
  }
  
  func didFisishChallengeName(challengeName: String, isPublic: Bool) {
    self.challengeName = challengeName
    self.isPublic = isPublic
    attachChallengeGoal()
  }
}

// MARK: ChallengeGoalListener
extension ChallengeOrganizeCoordinator: ChallengeGoalListener {
  func didTapBackButtonAtChallengeGoal() {
    detachChallengeGoal(animated: true)
  }
  
  func didFisishChallengeGoal(challengeGoal: String, proveTime: String, endDate: Date) {
    self.challengeGoal = challengeGoal
    self.challengeProveTime = proveTime
    self.challengeEndDate = endDate
    attachChallengeCover()
  }
}

// MARK: ChallengeCoverListener
extension ChallengeOrganizeCoordinator: ChallengeCoverListener {
  func didTapBackButtonAtChallengeCover() {
    detachChallengeCover(animated: true)
  }
  
  func didFinishedChallengeCover(coverImage: UIImageWrapper) {
    self.challengeCover = coverImage
    attachChallengeRule()
  }
}

// MARK: ChallengeRuleListener
extension ChallengeOrganizeCoordinator: ChallengeRuleListener {
  func didTapBackButtonAtChallengeRule() {
    detachChallengeRule(animated: true)
  }
  
  func didFinishChallengeRules(challengeRules: [String]) {
    self.challengeRule = challengeRules
    attachChallengeHashtag()
  }
}

// MARK: ChallengeHashTagListener
extension ChallengeOrganizeCoordinator: ChallengeHashtagListener {
  func didTapBackButtonAtChallengeHashtag() {
    detachChallengeHashtag(animated: true)
  }
  
  func didFinishChallengeHashtags(challengeHashtags: [String]) {
    self.challengeHashtags = challengeHashtags
    attachChallengePreview()
  }
}

// MARK: ChallengePreviewListener
extension ChallengeOrganizeCoordinator: ChallengePreviewListener {
  func didTapBackButtonAtChallengePreview() {
    detachChallengePreview(animated: true)
  }
  
  func didFinishOrganizeChallenge() {
    // TODO: 챌린지화면으로 넘어가기
  }
}
