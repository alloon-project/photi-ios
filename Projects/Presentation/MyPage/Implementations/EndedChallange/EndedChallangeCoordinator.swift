//
//  EndedChallengeCoordinator.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

protocol EndedChallengeListener: AnyObject {
  func didTapBackButtonAtEndedChallenge()
}

protocol EndedChallangePresentable {
  func configureEndedChallengeCount(_ count: Int)
}

final class EndedChallengeCoordinator: ViewableCoordinator<EndedChallangePresentable> {
  weak var listener: EndedChallengeListener?
  
  private let endedChallengeCount: Int
  private let viewModel: EndedChallengeViewModel
  
  init(
    endedChallengeCount: Int,
    viewControllerable: ViewControllerable,
    viewModel: EndedChallengeViewModel
  ) {
    self.endedChallengeCount = endedChallengeCount
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    super.start()
    presenter.configureEndedChallengeCount(endedChallengeCount)
  }
}

// MARK: - EndedChallengeCoordinatable
extension EndedChallengeCoordinator: EndedChallengeCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtEndedChallenge()
  }
  
  func attachChallengeDetail() { }
  
  func detachChallengeDetail() { }
}
