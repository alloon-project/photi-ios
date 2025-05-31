//
//  ModifyChallengeNameCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 5/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol ModifyChallengeNameListener: AnyObject {
  func didTapBackButtonAtModifyChallengeName()
  func modifiedChallengeName(name: String)
}

protocol ModifyChallengeNamePresentable { }

final class ModifyChallengeNameCoordinator: ViewableCoordinator<ModifyChallengeNamePresentable> {
  weak var listener: ModifyChallengeNameListener?
  
  private let viewModel: ModifyChallengeNameViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ModifyChallengeNameViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension ModifyChallengeNameCoordinator: ModifyChallengeNameCoordinatable {
  func modifiedChallengeName(name: String) {
    listener?.modifiedChallengeName(name: name)
  }
  
  func didTapBackButtonAtModifyChallengeName() {
    listener?.didTapBackButtonAtModifyChallengeName()
  }
}
