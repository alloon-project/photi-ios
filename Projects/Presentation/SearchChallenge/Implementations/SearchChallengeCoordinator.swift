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
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: SearchChallengeViewModel,
    challengeOrganizeContainable: ChallengeOrganizeContainable,
    recommendedChallengesContainable: RecommendedChallengesContainable,
    recentChallengesContainable: RecentChallengesContainable
  ) {
    self.viewModel = viewModel
    self.organizeContainable = challengeOrganizeContainable
    self.recommendedChallengesContainable = recommendedChallengesContainable
    self.recentChallengesContainable = recentChallengesContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    attachSegments()
  }
  
  func attachSegments() {
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
private extension SearchChallengeCoordinator {
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
  
  func detachSearchResult() {
    guard let coordinater = searchResultCoordinator else { return }
    viewControllerable.popViewController(animated: true)
    removeChild(coordinater)
    self.searchResultCoordinator = nil
  }
  }

// MARK: - SearchChallengeCoordinatable
extension SearchChallengeCoordinator: SearchChallengeCoordinatable {
  func didTapChallengeOrganize() {
    attachChallengeOrganize()
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
  func requestAttachChallengeAtRecommendedChallenges(challengeId: Int) { }
}

// MARK: - RecentChallengesListener
extension SearchChallengeCoordinator: RecentChallengesListener {
  func requestAttachChallengeAtRecentChallenges(challengeId: Int) { }
}

// MARK: - SearchResultListener
extension SearchChallengeCoordinator: SearchResultListener {
  func didTapBackButtonAtSearchResult() {
    detachSearchResult()
  }
}
