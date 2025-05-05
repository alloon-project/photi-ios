//
//  ChallengeNameCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeNameListener: AnyObject {
  func didTapBackButtonAtChallengeName()
  func didFisishChallengeName(challengeName: String, isPublic: Bool)
}

protocol ChallengeNamePresentable { }

final class ChallengeNameCoordinator: ViewableCoordinator<ChallengeNamePresentable> {
  weak var listener: ChallengeNameListener?
  
  private let viewModel: ChallengeNameViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeNameViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension ChallengeNameCoordinator: ChallengeNameCoordinatable {
  func attachChallengeGoal(challengeName: String, isPublic: Bool) {
    listener?.didFisishChallengeName(challengeName: challengeName, isPublic: isPublic)
  }
  
  func didTapBackButtonAtChallengeName() {
    listener?.didTapBackButtonAtChallengeName()
  }
}

