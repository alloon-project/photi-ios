//
//  ChallengeStartCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ChallengeStartListener: AnyObject {
  func didTapBackButtonAtChallengeStart()
  func didFinishChallengeStart()
}

protocol ChallengeStartPresentable { }

final class ChallengeStartCoordinator: ViewableCoordinator<ChallengeStartPresentable> {
  weak var listener: ChallengeStartListener?
  
  private let viewModel: ChallengeStartViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeStartViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension ChallengeStartCoordinator: ChallengeStartCoordinatable {
  func didFisishChallengeStart() {
    listener?.didFinishChallengeStart()
  }
  
  func didTapBackButton() {
    listener?.didTapBackButtonAtChallengeStart()
  }
}
