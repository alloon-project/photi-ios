//
//  SearchChallengeCoordinator.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Challenge
import SearchChallenge

protocol SearchChallengePresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...)
}

final class SearchChallengeCoordinator: ViewableCoordinator<SearchChallengePresentable> {
  weak var listener: SearchChallengeListener?

  private let viewModel: SearchChallengeViewModel
  
  private var organizeNavigationControllerable: NavigationControllerable?
  private let organizeContainable: ChallengeOrganizeContainable
  private var organizeCoordinator: Coordinating?
  
  private let recommendedChallengesContainable: RecommendedChallengesContainable
  private var recommendedChallengesCoordinator: ViewableCoordinating?
  
  private let recentChallengesContainable: RecentChallengesContainable
  private var recentChallengesCoordinator: ViewableCoordinating?
  
  private let searchResultContainable: SearchResultContainable
  private var searchResultCoordinator: ViewableCoordinating?
  
  private let challengeContainable: ChallengeContainable
  private var challengeCoordinator: ViewableCoordinating?
  
  private let noneMemberChallengeContainable: NoneMemberChallengeContainable
  private var noneMemberchallengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: SearchChallengeViewModel,
    challengeOrganizeContainable: ChallengeOrganizeContainable,
    recommendedChallengesContainable: RecommendedChallengesContainable,
    recentChallengesContainable: RecentChallengesContainable,
    searchResultContainable: SearchResultContainable,
    challengeContainable: ChallengeContainable,
    noneMemberChallengeContainable: NoneMemberChallengeContainable
  ) {
    self.viewModel = viewModel
    self.organizeContainable = challengeOrganizeContainable
    self.recommendedChallengesContainable = recommendedChallengesContainable
    self.recentChallengesContainable = recentChallengesContainable
    self.searchResultContainable = searchResultContainable
    self.challengeContainable = challengeContainable
    self.noneMemberChallengeContainable = noneMemberChallengeContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    attachSegments()
  }
  
  private func attachSegments() {
    let recommendedChallenges = recommendedChallengesContainable.coordinator(listener: self)
    let recentChallenges = recentChallengesContainable.coordinator(listener: self)
    
    presenter.attachViewControllerables(
      recommendedChallenges.viewControllerable,
      recentChallenges.viewControllerable
    )
    addChild(recommendedChallenges)
    addChild(recentChallenges)
    self.recommendedChallengesCoordinator = recommendedChallenges
    self.recentChallengesCoordinator = recentChallenges
  }
}

// MARK: - ChallengeOrganize
extension SearchChallengeCoordinator {
  func attachChallengeOrganize() {
    guard organizeCoordinator == nil else { return }
    
    let navigation = NavigationControllerable()
    let coordinater = organizeContainable.coordinator(navigationControllerable: navigation, listener: self)
    viewControllerable.present(
      navigation,
      animated: true,
      modalPresentationStyle: .overFullScreen
    )
    addChild(coordinater)
    self.organizeNavigationControllerable = navigation
    self.organizeCoordinator = coordinater
  }
  
  func detachChallengeOrganize() {
    guard let coordinater = organizeCoordinator else { return }
    organizeNavigationControllerable?.dismiss()
    removeChild(coordinater)
    self.organizeNavigationControllerable = nil
    self.organizeCoordinator = nil
  }
}

// MARK: - SearchResult
private extension SearchChallengeCoordinator {
  func attachSearchResult() {
    guard searchResultCoordinator == nil else { return }
    let coordinater = searchResultContainable.coordinator(listener: self)
    viewControllerable.pushViewController(coordinater.viewControllerable, animated: false)
    addChild(coordinater)
    self.searchResultCoordinator = coordinater
  }
  
  func detachSearchResult() {
    guard let coordinater = searchResultCoordinator else { return }
    viewControllerable.popViewController(animated: true)
    viewControllerable.uiviewController.showTabBar(animted: true)
    removeChild(coordinater)
    self.searchResultCoordinator = nil
  }
}

// MARK: - Challenge
extension SearchChallengeCoordinator {
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
    viewControllerable.uiviewController.showTabBar(animted: true)
    removeChild(coordinater)
    self.challengeCoordinator = nil
  }
}

// MARK: - NoneMemberChallenge
extension SearchChallengeCoordinator {
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

// MARK: - SearchChallengeCoordinatable
extension SearchChallengeCoordinator: SearchChallengeCoordinatable {
  func didStartSearch() {
    attachSearchResult()
  }
}

// MARK: - ChallengeOrganizeListener
extension SearchChallengeCoordinator: ChallengeOrganizeListener {
  func didTapBackButtonAtChallengeOrganize() {
    detachChallengeOrganize()
  }
}

// MARK: - RecommendedChallengesListener
extension SearchChallengeCoordinator: RecommendedChallengesListener {
  func requestAttachChallengeAtRecommendedChallenges(challengeId: Int) {
    Task { await viewModel.decideRouteForChallenge(id: challengeId) }
  }
}

// MARK: - RecentChallengesListener
extension SearchChallengeCoordinator: RecentChallengesListener {
  func requestAttachChallengeAtRecentChallenges(challengeId: Int) {
    Task { await viewModel.decideRouteForChallenge(id: challengeId) }
  }
}

// MARK: - SearchResultListener
extension SearchChallengeCoordinator: SearchResultListener {
  func authenticatedFailedAtSearchResult() {
    listener?.authenticatedFailedAtSearchChallenge()
  }
  
  func didTapBackButtonAtSearchResult() {
    detachSearchResult()
  }
}

// MARK: - ChallengeListener
extension SearchChallengeCoordinator: ChallengeListener {
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
    listener?.authenticatedFailedAtSearchChallenge()
  }
}

// MARK: - NoneMemberChallengeListener
extension SearchChallengeCoordinator: NoneMemberChallengeListener {
  func didTapBackButtonAtNoneMemberChallenge() {
    detachNonememberChallenge(willRemoveView: true)
  }
  
  func didJoinChallenge(id: Int) {
    detachNonememberChallenge(willRemoveView: false)
    guard
       let navigationController = viewControllerable.uiviewController.navigationController,
       let baseVC = navigationController.viewControllers.first as? ViewControllerable // A
     else { return }
    
    viewControllerable.setViewControllers([baseVC], animated: false)
    attachChallenge(id: id)
  }
  
  func authenticatedFailedAtNoneMemberChallenge() {
    listener?.authenticatedFailedAtSearchChallenge()
  }
}
