//
//  SearchResultCoordinator.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Challenge
import Core

protocol SearchResultListener: AnyObject {
  func didTapBackButtonAtSearchResult()
  func authenticatedFailedAtSearchResult()
  func didLoginAtSearchResult()
}

@MainActor protocol SearchResultPresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...)
}

final class SearchResultCoordinator: ViewableCoordinator<SearchResultPresentable> {
  weak var listener: SearchResultListener?

  private let viewModel: SearchResultViewModel
  
  private let challengeTitleReulstContainable: ChallengeTitleResultContainable
  private var challengeTitleReulstCoordinator: ViewableCoordinating?
  
  private let hashTagResultContainable: HashTagResultContainable
  private var hashTagResultCoordinator: ViewableCoordinating?
  
  private let challengeContainable: ChallengeContainable
  private var challengeCoordinator: ViewableCoordinating?
  
  private let noneMemberChallengeContainable: NoneMemberChallengeContainable
  private var noneMemberchallengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: SearchResultViewModel,
    challengeTitleReulstContainable: ChallengeTitleResultContainable,
    hashTagResultContainable: HashTagResultContainable,
    challengeContainable: ChallengeContainable,
    noneMemberChallengeContainable: NoneMemberChallengeContainable
  ) {
    self.viewModel = viewModel
    self.challengeTitleReulstContainable = challengeTitleReulstContainable
    self.hashTagResultContainable = hashTagResultContainable
    self.challengeContainable = challengeContainable
    self.noneMemberChallengeContainable = noneMemberChallengeContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    attachSegments()
  }
  
  private func attachSegments() {
    let challengeTitleReulst = challengeTitleReulstContainable.coordinator(
      listener: self,
      searchInput: viewModel.titleSearchInput
    )
    let hashTagResult = hashTagResultContainable.coordinator(
      listener: self,
      searchInput: viewModel.hashTagSearchInput
    )
    
    Task {
      await presenter.attachViewControllerables(
        challengeTitleReulst.viewControllerable,
        hashTagResult.viewControllerable
      )
    }
    addChild(challengeTitleReulst)
    addChild(hashTagResult)
    self.challengeTitleReulstCoordinator = challengeTitleReulst
    self.hashTagResultCoordinator = hashTagResult
  }
}

// MARK: - Challenge
extension SearchResultCoordinator {
  func attachChallenge(id: Int) {
    guard challengeCoordinator == nil else { return }
    let coordinater = challengeContainable.coordinator(
      listener: self,
      challengeId: id,
      presentType: .default
    )
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    addChild(coordinater)
    self.challengeCoordinator = coordinater
  }
  
  func detachChallenge() {
    guard let coordinater = challengeCoordinator else { return }
    viewControllerable.popViewController(animated: true)
    removeChild(coordinater)
    self.challengeCoordinator = nil
  }
}

// MARK: - NoneMemberChallenge
extension SearchResultCoordinator {
  func attachNonememberChallenge(id: Int) {
    guard noneMemberchallengeCoordinator == nil else { return }
    let coordinater = noneMemberChallengeContainable.coordinator(listener: self, challengeId: id)
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: true)
    addChild(coordinater)
    self.noneMemberchallengeCoordinator = coordinater
  }
  
  func detachNonememberChallenge(willRemoveView: Bool) {
    guard let coordinater = noneMemberchallengeCoordinator else { return }
    
    if willRemoveView {
      viewControllerable.popViewController(animated: true)
      viewControllerable.uiviewController.showTabBar(animted: true)
    }

    removeChild(coordinater)
    self.noneMemberchallengeCoordinator = nil
  }
}

// MARK: - SearchResultCoordinatable
extension SearchResultCoordinator: SearchResultCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtSearchResult()
  }
}

// MARK: - ChallengeTitleResultListener
extension SearchResultCoordinator: ChallengeTitleResultListener {
  func didTapChallengeAtChallengeTitleResult(challengeId: Int) {
    Task { await viewModel.decideRouteForChallenge(id: challengeId) }
  }
}

// MARK: - HashTagResultListener
extension SearchResultCoordinator: HashTagResultListener {
  func didTapChallengeAtHashTagResult(challengeId: Int) {
    Task { await viewModel.decideRouteForChallenge(id: challengeId) }
  }
}

// MARK: - ChallengeListener
extension SearchResultCoordinator: ChallengeListener {
  func didTapBackButtonAtChallenge() {
    detachChallenge()
  }
  
  func shouldDismissChallenge() {
    detachChallenge()
  }
  
  func leaveChallenge(challengeId: Int) {
    detachChallenge()
  }
  
  func authenticatedFailedAtChallenge() {
    listener?.authenticatedFailedAtSearchResult()
  }
}

// MARK: - NoneMemberChallengeListener
extension SearchResultCoordinator: NoneMemberChallengeListener {
  func didTapBackButtonAtNoneMemberChallenge() {
    detachNonememberChallenge(willRemoveView: true)
  }
  
  func shouldDismissNoneMemberChallenge() {
    detachNonememberChallenge(willRemoveView: true)
  }
  
  func didJoinChallenge(id: Int) {
    detachNonememberChallenge(willRemoveView: false)
    guard
       let navigationController = viewControllerable.uiviewController.navigationController,
       let baseVC = navigationController.viewControllers.first as? ViewControllerable
     else { return }
    
    viewControllerable.setViewControllers([baseVC], animated: false)
    attachChallenge(id: id)
  }
  
  func alreadyJoinedChallenge(id: Int) {
    detachNonememberChallenge(willRemoveView: false)
    guard
       let navigationController = viewControllerable.uiviewController.navigationController,
       let baseVC = navigationController.viewControllers.first as? ViewControllerable
     else { return }
    
    viewControllerable.setViewControllers([baseVC], animated: false)
    attachChallenge(id: id)
  }
  
  func authenticatedFailedAtNoneMemberChallenge() {
    listener?.authenticatedFailedAtSearchResult()
  }
  
  func didLoginAtNoneMemberChallenge() {
    listener?.didLoginAtSearchResult()
  }
}
