//
//  ChallengeCoordinator.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator
import Challenge
import Report

protocol ChallengePresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...)
  func didChangeContentOffsetAtMainContainer(_ offset: Double)
  func presentChallengeNotFoundWaring()
  func presentNetworkWarning(reason: String?)
  func presentFinishModifying()
  func presentChallengeReported()
  func presentShareActivity(challengeId: Int, inviteCode: String?, challengeName: String)
}

final class ChallengeCoordinator: ViewableCoordinator<ChallengePresentable> {
  weak var listener: ChallengeListener?

  private let viewModel: ChallengeViewModel
  private let presentType: ChallengePresentType
  
  private let feedContainer: FeedContainable
  private var feedCoordinator: ViewableCoordinating?
  
  private let participantContainer: ParticipantContainable
  private var participantCoordinator: ViewableCoordinating?
  
  private let descriptionContainer: DescriptionContainable
  private var descriptionCoordinator: ViewableCoordinating?
  
  private let reportContainer: ReportContainable
  private var reportCoordinator: ViewableCoordinating?
  
  private let modifyContainer: ChallengeModifyContainable
  private var modifyCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeViewModel,
    initialPresentType: ChallengePresentType,
    feedContainer: FeedContainable,
    descriptionContainer: DescriptionContainable,
    participantContainer: ParticipantContainable,
    reportContainer: ReportContainable,
    modifyContainer: ChallengeModifyContainable
  ) {
    self.viewModel = viewModel
    self.presentType = initialPresentType
    self.feedContainer = feedContainer
    self.descriptionContainer = descriptionContainer
    self.participantContainer = participantContainer
    self.reportContainer = reportContainer
    self.modifyContainer = modifyContainer
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    Task { await attachSegments() }
  }
  
  @MainActor func attachSegments() async {
    guard let challengeName = await viewModel.fetchChallenge()?.name else { return }
    let challengeId = viewModel.challengeId
    
    let feedCoordinator = feedContainer.coordinator(
      challengeName: challengeName,
      challengeId: challengeId,
      listener: self,
      presentType: presentType
    )
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

// MARK: - Report
@MainActor extension ChallengeCoordinator {
  func attachReport(reportType: ReportType) {
    guard reportCoordinator == nil else { return }
    
    let coordinator = reportContainer.coordinator(listener: self, reportType: reportType)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.reportCoordinator = coordinator
  }
  
  func detachReport() {
    guard let coordinator = reportCoordinator else { return }
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.reportCoordinator = nil
  }
}

// MARK: - ChallengeEdit
@MainActor extension ChallengeCoordinator {
  func attachChallengeEdit(model: ModifyPresentationModel, challengeId: Int) {
    guard modifyCoordinator == nil else { return }
    
    let coordinator = modifyContainer.coordinator(
      listener: self,
      viewPresentationMdoel: model,
      challengeId: challengeId
    )
    
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.modifyCoordinator = coordinator
  }
  
  func detachChallengeEdit() {
    guard let coordinator = modifyCoordinator else { return }
    
    removeChild(coordinator)
    self.modifyCoordinator = nil
    viewControllerable.popViewController(animated: true)
  }
}

// MARK: - ChallengeCoordinatable
extension ChallengeCoordinator: ChallengeCoordinatable {
  func didTapConfirmButtonAtAlert() {
    listener?.shouldDismissChallenge()
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtChallenge()
  }
  
  func leaveChallenge(challengeId: Int) {
    listener?.leaveChallenge(challengeId: challengeId)
  }
  
  func attachChallengeReport(challengeId: Int) {
    attachReport(reportType: .challenge(challengeId)) 
  }
  
  func authenticatedFailed() {
    listener?.authenticatedFailedAtChallenge()
  }
  
  func didTapShareButton(challengeId: Int, inviteCode: String?, challengeName: String) {
    presenter.presentShareActivity(
      challengeId: challengeId,
      inviteCode: inviteCode,
      challengeName: challengeName
    )
  }
}

// MARK: - FeedListener
extension ChallengeCoordinator: FeedListener {
  func didChangeContentOffsetAtFeed(_ offset: Double) {
    presenter.didChangeContentOffsetAtMainContainer(offset)
  }
  
  func authenticatedFailedAtFeed() {
    listener?.authenticatedFailedAtChallenge()
  }
  
  func networkUnstableAtFeed(reason: String?) {
    presenter.presentNetworkWarning(reason: reason)
  }
  
  func challengeNotFoundAtFeed() {
    presenter.presentChallengeNotFoundWaring()
  }
  
  func requestReportAtFeed(feedId: Int) {
    Task { await attachReport(reportType: .feed(feedId)) }
  }
  
  func deleteFeed(challengeId: Int, feedId: Int) {
    listener?.deleteFeed(challengeId: challengeId, feedId: feedId)
  }
}

// MARK: - DescriptionListener
extension ChallengeCoordinator: DescriptionListener {
  func authenticatedFailedAtDescription() {
    listener?.authenticatedFailedAtChallenge()
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
    listener?.authenticatedFailedAtChallenge()
  }
  
  func networkUnstableAtParticipant() {
    presenter.presentNetworkWarning(reason: nil)
  }
}

// MARK: - ReportListener
extension ChallengeCoordinator: ReportListener {
  func didInquiryApplicated() {
    Task { await detachReport() }
    presenter.presentChallengeReported()
  }
  
  func didTapBackButtonAtReport() {
    Task { await detachReport() }
  }
}

// MARK: - ModifyListener
extension ChallengeCoordinator: ModifyChallengeListener {
  func challengeModified() {
    Task { await detachChallengeEdit() }
    presenter.presentFinishModifying()
  }
  
  func didTapBackButtonAtModifyChallenge() {
    Task { await detachChallengeEdit() }
  }
  
  func didTapAlertButtonAtModifyChallenge() {
    Task { await detachChallengeEdit() }
  }
}
