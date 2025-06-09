//
//  ChallengeModifyCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 5/17/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Challenge
import Core

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
    self.modifyNameContainer = modifyNameContainer
    self.modifyGoalContainer = modifyGoalContainer
    self.modifyCoverContainer = modifyCoverContainer
    self.modifyHashtagContainer = modifyHashtagContainer
    self.modifyRuleContainer = modifyRuleContainer
    self.viewModel = viewModel
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

// MARK: - Detach
private extension ChallengeModifyCoordinator {
  func detachModifyName() {
    guard let coordinator = modifyNameCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyNameCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
  
  func detachModifyGoal() {
    guard let coordinator = modifyGoalCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyGoalCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
  
  func detachModifyCover() {
    guard let coordinator = modifyCoverCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyCoverCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
  
  func detachModifyHashtag() {
    guard let coordinator = modifyHashtagCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyHashtagCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
  
  func detachModifyRule() {
    guard let coordinator = modifyRuleCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyRuleCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
}

// MARK: - ChallengeModifyCoordinatable
extension ChallengeModifyCoordinator: ChallengeModifyCoordinatable {
  func attachModifyName() {
    guard modifyNameCoordinator == nil else { return }
    
    let coordinater = modifyNameContainer.coordinator(mode: .modify, listener: self)
    addChild(coordinater)
    
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.modifyNameCoordinator = coordinater
  }
  
  func attachModifyGoal() {
    guard modifyGoalCoordinator == nil else { return }
    
    let coordinater = modifyGoalContainer.coordinator(mode: .modify, listener: self)
    addChild(coordinater)
    
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    self.modifyNameCoordinator = coordinater
  }
  
  func attachModifyCover() {}
  
  func attachModifyHashtag() {}
  
  func attachModifyRule() {}
  
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

extension ChallengeModifyCoordinator: ChallengeNameListener {
  func didTapBackButtonAtChallengeName() { }
  
  func didFisishChallengeName(challengeName: String, isPublic: Bool) {}
}

extension ChallengeModifyCoordinator: ChallengeGoalListener {
  func didTapBackButtonAtChallengeGoal() {}
  
  func didFisishChallengeGoal(challengeGoal: String, proveTime: String, endDate: String) {}
}
