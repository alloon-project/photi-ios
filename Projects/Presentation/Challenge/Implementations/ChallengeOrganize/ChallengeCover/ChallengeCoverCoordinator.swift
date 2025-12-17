//
//  ChallengeCoverCoordinator.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Coordinator
import CoreUI

protocol ChallengeCoverListener: AnyObject {
  func didTapBackButtonAtChallengeCover()
  func didFinishedChallengeCover(coverImage: UIImageWrapper)
}

protocol ChallengeCoverPresentable { }

final class ChallengeCoverCoordinator: ViewableCoordinator<ChallengeCoverPresentable> {
  weak var listener: ChallengeCoverListener?
  
  private let viewModel: ChallengeCoverViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeCoverViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension ChallengeCoverCoordinator: ChallengeCoverCoordinatable {
  func didFinishedChallengeCover(coverImage: UIImageWrapper) {
    listener?.didFinishedChallengeCover(coverImage: coverImage)
  }
  
  func didTapBackButtonAtChallengeCover() {
    listener?.didTapBackButtonAtChallengeCover()
  }
}
