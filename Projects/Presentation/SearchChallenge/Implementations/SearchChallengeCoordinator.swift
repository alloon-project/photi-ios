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

protocol SearchChallengePresentable { }

final class SearchChallengeCoordinator: ViewableCoordinator<SearchChallengePresentable> {
  weak var listener: SearchChallengeListener?

  private let viewModel: SearchChallengeViewModel
  
  private var organizeNavigationControllerable: NavigationControllerable?
  private let organizeContainable: ChallengeOrganizeContainable
  private var organizeCoordinator: Coordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: SearchChallengeViewModel,
    challengeOrganizeContainable: ChallengeOrganizeContainable
  ) {
    self.viewModel = viewModel
    
    self.organizeContainable = challengeOrganizeContainable
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
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

extension SearchChallengeCoordinator: SearchChallengeCoordinatable {
  func didTapChallengeOrganize() {
    attachChallengeOrganize()
  }
}

// MARK: - Challenge Organize Listener
extension SearchChallengeCoordinator: ChallengeOrganizeListener {
  func didTapBackButtonAtChallengeOrganize() {
    detachChallengeOrganize()
  }
}
