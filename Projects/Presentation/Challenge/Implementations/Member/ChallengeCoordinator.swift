//
//  ChallengeCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import Challenge

protocol ChallengePresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...)
  func didChangeContentOffsetAtMainContainer(_ offset: Double)
  func presentDidChangeGoalToastView()
  func presentChallengeNotFoundWaring()
  func presentNetworkWarning(reason: String?)
  func presentLoginTrrigerWarning()
}

final class ChallengeCoordinator: ViewableCoordinator<ChallengePresentable> {
  weak var listener: ChallengeListener?

  private let viewModel: ChallengeViewModel
  
  private let feedContainer: FeedContainable
  private var feedCoordinator: ViewableCoordinating?
  
  private let participantContainer: ParticipantContainable
  private var participantCoordinator: ViewableCoordinating?
  
  private let descriptionContainer: DescriptionContainable
  private var descriptionCoordinator: ViewableCoordinating?
  
  private let editChallengeGoalContainer: EnterChallengeGoalContainable
  private var editChallengeGoalCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeViewModel,
    feedContainer: FeedContainable,
    descriptionContainer: DescriptionContainable,
    participantContainer: ParticipantContainable,
    editChallengeGoalContainer: EnterChallengeGoalContainer
  ) {
    self.viewModel = viewModel
    self.feedContainer = feedContainer
    self.descriptionContainer = descriptionContainer
    self.participantContainer = participantContainer
    self.editChallengeGoalContainer = editChallengeGoalContainer
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    attachSegments()
  }
  
  func attachSegments() {
    let challengeId = viewModel.challengeId
    let feedCoordinator = feedContainer.coordinator(challengeId: challengeId, listener: self)
    let descriptionCoordinator = descriptionContainer.coordinator(challengeId: challengeId, listener: self)
    let participantCoordinator = participantContainer.coordinator(listener: self)
    
    presenter.attachViewControllerables(
      feedCoordinator.viewControllerable,
      descriptionCoordinator.viewControllerable,
      participantCoordinator.viewControllerable
    )
    addChild(feedCoordinator)
    addChild(descriptionCoordinator)
    addChild(participantCoordinator)
    self.feedCoordinator = feedCoordinator
    self.descriptionCoordinator = descriptionCoordinator
    self.participantCoordinator = participantCoordinator
  }
}

// MARK: - ChallengeCoordinatable
extension ChallengeCoordinator: ChallengeCoordinatable {
  func didTapConfirmButtonAtAlert() {
    listener?.shouldDismissChallenge()
  }
  
  func didTapLoginButtonAtAlert() {
    listener?.requestLoginAtChallenge()
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtChallenge()
  }
}

// MARK: - EditChallengeGoal
extension ChallengeCoordinator {
  func attachEditChallengeGoal(
    challengeID: Int,
    goal: String,
    challengeName: String
  ) {
    guard editChallengeGoalCoordinator == nil else { return }
    
    let coordinator = editChallengeGoalContainer.coordinator(
      mode: .edit(goal: goal),
      challengeID: challengeID,
      challengeName: challengeName,
      listener: self
    )
    
    addChild(coordinator)
    self.editChallengeGoalCoordinator = coordinator
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
  }
  
  func detachEditChallengeGoal(completion: (() -> Void)? = nil) {
    guard let coordinator = editChallengeGoalCoordinator else { return }
    
    removeChild(coordinator)
    self.editChallengeGoalCoordinator = nil
    viewControllerable.popViewController(animated: true) {
      completion?()
    }
  }
}

// MARK: - FeedListener
extension ChallengeCoordinator: FeedListener {
  func didChangeContentOffsetAtFeed(_ offset: Double) {
    presenter.didChangeContentOffsetAtMainContainer(offset)
  }
  
  func authenticatedFailedAtFeed() {
    presenter.presentLoginTrrigerWarning()
  }
  
  func networkUnstableAtFeed(reason: String?) {
    presenter.presentNetworkWarning(reason: reason)
  }
  
  func challengeNotFoundAtFeed() {
    presenter.presentChallengeNotFoundWaring()
  }
}

// MARK: - DescriptionListener
extension ChallengeCoordinator: DescriptionListener { }

// MARK: - ParticipantListener
extension ChallengeCoordinator: ParticipantListener {
  func didChangeContentOffsetAtParticipant(_ offset: Double) {
    presenter.didChangeContentOffsetAtMainContainer(offset)
  }
  
  func didTapEditButton(
    challengeID: Int,
    goal: String,
    challengeName: String
  ) {
    attachEditChallengeGoal(
      challengeID: challengeID,
      goal: goal,
      challengeName: challengeName
    )
  }
}

// MARK: - EditChallengeGoalListener
extension ChallengeCoordinator: EnterChallengeGoalListener {
  func didTapBackButtonAtEnterChallengeGoal() {
    detachEditChallengeGoal()
  }

  func didFinishEnterChallengeGoal() {
    // TODO: API 연결 이후 수정 예정
    detachEditChallengeGoal { [weak self] in
      self?.presenter.presentDidChangeGoalToastView()
    }
  }
  
  func requestLoginAtEnterChallengeGoal() {
    listener?.requestLoginAtChallenge()
  }
}
