//
//  ChallengeHashtagCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator

protocol ChallengeHashtagListener: AnyObject {
  func didTapBackButtonAtChallengeHashtag()
  func didFinishChallengeHashtags(challengeHashtags: [String])
}

protocol ChallengeHashtagPresentable { }

final class ChallengeHashtagCoordinator: ViewableCoordinator<ChallengeHashtagPresentable> {
  weak var listener: ChallengeHashtagListener?
  
  private let viewModel: ChallengeHashtagViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeHashtagViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension ChallengeHashtagCoordinator: ChallengeHashtagCoordinatable {
  func didFinishedAtChallengeHashtag(challengeHashtags: [String]) {
    listener?.didFinishChallengeHashtags(challengeHashtags: challengeHashtags)
  }
  
  func didTapBackButtonAtChallengeHashtag() {
    listener?.didTapBackButtonAtChallengeHashtag()
  }
}
