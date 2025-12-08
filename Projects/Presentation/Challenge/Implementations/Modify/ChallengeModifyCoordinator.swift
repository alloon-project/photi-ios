//
//  ChallengeModifyCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 5/17/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import Challenge
import CoreUI

protocol ModifyChallengeListener: AnyObject {
  func challengeModified()
  func didTapBackButtonAtModifyChallenge()
  func didTapAlertButtonAtModifyChallenge()
}

protocol ChallengeModifyPresentable {
  func setLeftView(
    title: String,
    hashtags: [String],
    verificationTime: String,
    goal: String
  )
  
  func setRightView(
    imageURLString: String,
    rules: [String],
    deadLine: String
  )
  
  func modifyName(name: String)
  func modifyGoal(goal: String, verificationTime: String, endDate: String)
  func modifyCover(image: UIImageWrapper)
  func modifyHashtags(hashtags: [String])
  func modifyRules(rules: [String])
}

final class ChallengeModifyCoordinator: ViewableCoordinator<ChallengeModifyPresentable> {
  weak var listener: ModifyChallengeListener?
  private let viewPresentationModel: ModifyPresentationModel
  private let viewModel: ChallengeModifyViewModel
  
  private let modifyNameContainer: ChallengeNameContainable
  private var modifyNameCoordinator: ViewableCoordinating?
  
  private let modifyGoalContainer: ChallengeGoalContainable
  private var modifyGoalCoordinator: ViewableCoordinating?
  
  private let modifyCoverContainer: ChallengeCoverContainable
  private var modifyCoverCoordinator: ViewableCoordinating?
  
  private let modifyHashtagContainer: ChallengeHashtagContainable
  private var modifyHashtagCoordinator: ViewableCoordinating?
  
  private let modifyRuleContainer: ChallengeRuleContainable
  private var modifyRuleCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeModifyViewModel,
    viewPresentationModel: ModifyPresentationModel,
    modifyNameContainer: ChallengeNameContainable,
    modifyGoalContainer: ChallengeGoalContainable,
    modifyCoverContainer: ChallengeCoverContainable,
    modifyHashtagContainer: ChallengeHashtagContainable,
    modifyRuleContainer: ChallengeRuleContainable
  ) {
    self.viewModel = viewModel
    self.modifyNameContainer = modifyNameContainer
    self.modifyGoalContainer = modifyGoalContainer
    self.modifyCoverContainer = modifyCoverContainer
    self.modifyHashtagContainer = modifyHashtagContainer
    self.modifyRuleContainer = modifyRuleContainer
    self.viewPresentationModel = viewPresentationModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    presenter.setLeftView(
      title: viewPresentationModel.title,
      hashtags: viewPresentationModel.hashtags,
      verificationTime: viewPresentationModel.verificationTime,
      goal: viewPresentationModel.goal
    )
    presenter.setRightView(
      imageURLString: viewPresentationModel.imageUrlString,
      rules: viewPresentationModel.rules,
      deadLine: viewPresentationModel.deadLine
    )
  }
}

// MARK: - ChallengeModifyCoordinatable
extension ChallengeModifyCoordinator: ChallengeModifyCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtModifyChallenge()
  }
  
  func didModifiedChallenge() {
    listener?.challengeModified()
  }
  
  func didTapAlert() {
    listener?.didTapAlertButtonAtModifyChallenge()
  }
}

// MARK: - ModifyName
@MainActor extension ChallengeModifyCoordinator {
  func attachModifyName() {
    guard modifyNameCoordinator == nil else { return }
    
    let coordinater = modifyNameContainer.coordinator(
      mode: .modify,
      title: self.viewPresentationModel.title,
      listener: self
    )
    addChild(coordinater)
    
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.modifyNameCoordinator = coordinater
  }
  
  func detachModifyName() {
    guard let coordinator = modifyNameCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyNameCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
}

// MARK: - ModifyGoal
@MainActor extension ChallengeModifyCoordinator {
  func attachModifyGoal() {
    guard modifyGoalCoordinator == nil else { return }
    
    let coordinater = modifyGoalContainer.coordinator(
      mode: .modify,
      goal: self.viewPresentationModel.goal,
      proveTime: self.viewPresentationModel.verificationTime,
      endDate: self.viewPresentationModel.deadLine,
      listener: self
    )
    addChild(coordinater)
    
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.modifyGoalCoordinator = coordinater
  }
  
  func detachModifyGoal() {
    guard let coordinator = modifyGoalCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyGoalCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
}

// MARK: - ModifyCover
@MainActor extension ChallengeModifyCoordinator {
  func attachModifyCover() {
    guard modifyCoverCoordinator == nil else { return }
    
    let coordinater = modifyCoverContainer.coordinator(mode: .modify, listener: self)
    addChild(coordinater)
    
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.modifyCoverCoordinator = coordinater
  }
  
  func detachModifyCover() {
    guard let coordinator = modifyCoverCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyCoverCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
}

// MARK: - ModifyHashtag
@MainActor extension ChallengeModifyCoordinator {
  func attachModifyHashtag() {
    guard modifyHashtagCoordinator == nil else { return }
    
    let coordinater = modifyHashtagContainer.coordinator(mode: .modify, listener: self)
    addChild(coordinater)
    
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.modifyHashtagCoordinator = coordinater
  }
  
  func detachModifyHashtag() {
    guard let coordinator = modifyHashtagCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyHashtagCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
}

// MARK: - ModifyRule
@MainActor extension ChallengeModifyCoordinator {
  func attachModifyRule() {
    guard modifyHashtagCoordinator == nil else { return }
    
    let coordinater = modifyRuleContainer.coordinator(
      mode: .modify,
      rules: viewPresentationModel.rules,
      listener: self
    )
    addChild(coordinater)
    
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.modifyRuleCoordinator = coordinater
  }
  
  func detachModifyRule() {
    guard let coordinator = modifyRuleCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyRuleCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
}

// MARK: ModifyChallenge Name Listener
extension ChallengeModifyCoordinator: ChallengeNameListener {
  func didTapBackButtonAtChallengeName() {
    Task { await detachModifyName() }
  }
  
  func didFisishChallengeName(challengeName: String, isPublic: Bool) {
    Task { await detachModifyName() }
    presenter.modifyName(name: challengeName)
  }
}

// MARK: ModifyChallenge Goal Listener
extension ChallengeModifyCoordinator: ChallengeGoalListener {
  func didTapBackButtonAtChallengeGoal() {
    Task { await detachModifyGoal() }
  }
  
  func didFisishChallengeGoal(challengeGoal: String, proveTime: String, endDate: String) {
    Task { await detachModifyGoal() }
    presenter.modifyGoal(goal: challengeGoal, verificationTime: proveTime, endDate: endDate)
  }
}

// MARK: ModifyChallenge Cover Listener
extension ChallengeModifyCoordinator: ChallengeCoverListener {
  func didTapBackButtonAtChallengeCover() {
    Task { await detachModifyCover() }
  }
  
  func didFinishedChallengeCover(coverImage: UIImageWrapper) {
    Task { await detachModifyCover() }
    presenter.modifyCover(image: coverImage)
  }
}

// MARK: ModifyChallenge Hashtag Listener
extension ChallengeModifyCoordinator: ChallengeHashtagListener {
  func didTapBackButtonAtChallengeHashtag() {
    Task { await detachModifyHashtag() }
  }
  
  func didFinishChallengeHashtags(challengeHashtags: [String]) {
    Task { await detachModifyHashtag() }
    presenter.modifyHashtags(hashtags: challengeHashtags)
  }
}

// MARK: ModifyChallenge Rule Listener
extension ChallengeModifyCoordinator: ChallengeRuleListener {
  func didTapBackButtonAtChallengeRule() {
    Task { await detachModifyRule() }
  }
  
  func didFinishChallengeRules(challengeRules: [String]) {
    Task { await detachModifyRule() }
    presenter.modifyRules(rules: challengeRules)
  }
}
