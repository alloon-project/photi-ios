//
//  ChallengeCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import Challenge
import Report

protocol ChallengePresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...)
  func didChangeContentOffsetAtMainContainer(_ offset: Double)
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
  
  private let reportContainer: ReportContainable
  private var reportCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeViewModel,
    feedContainer: FeedContainable,
    descriptionContainer: DescriptionContainable,
    participantContainer: ParticipantContainable,
    reportContainer: ReportContainable
  ) {
    self.viewModel = viewModel
    self.feedContainer = feedContainer
    self.descriptionContainer = descriptionContainer
    self.participantContainer = participantContainer
    self.reportContainer = reportContainer
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    attachSegments()
  }
  
  func attachSegments() {
    let challengeId = viewModel.challengeId
    let challengeName = viewModel.challengeName
    let feedCoordinator = feedContainer.coordinator(challengeId: challengeId, listener: self)
    let descriptionCoordinator = descriptionContainer.coordinator(challengeId: challengeId, listener: self)
    let participantCoordinator = participantContainer.coordinator(
      challengeId: challengeId,
      challengeName: challengeName,
      listener: self
    )
    
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
  
  func attachReport() {
    guard reportCoordinator == nil else { return }
    
    let coordinator = reportContainer.coordinator(listener: self, reportType: .challenge)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.reportCoordinator = coordinator
  }
  
  func leaveChallenge(isLastMember: Bool) {
    listener?.leaveChallenge(isDelete: isLastMember)
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
extension ChallengeCoordinator: DescriptionListener {
  func authenticatedFailedAtDescription() {
    presenter.presentLoginTrrigerWarning()
  }
  
  func networkUnstableAtDescription() {
    presenter.presentNetworkWarning(reason: nil)
  }
  
  func challengeNotFoundAtDescription() {
    presenter.presentChallengeNotFoundWaring()
  }
}

// MARK: - ParticipantListener
extension ChallengeCoordinator: ParticipantListener {
  func didChangeContentOffsetAtParticipant(_ offset: Double) {
    presenter.didChangeContentOffsetAtMainContainer(offset)
  }

  func authenticatedFailedAtParticipant() {
    presenter.presentLoginTrrigerWarning()
  }
  
  func networkUnstableAtParticipant() {
    presenter.presentNetworkWarning(reason: nil)
  }
  
  func requestLoginAtPariticipant() {
    listener?.requestLoginAtChallenge()
  }
}

// MARK: - ReportListener
extension ChallengeCoordinator: ReportListener {
  func detachReport() {
    guard let coordinator = reportCoordinator else { return }
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.reportCoordinator = nil
  }
}
