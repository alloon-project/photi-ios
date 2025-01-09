//
//  SearchChallengeCoordinator.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import SearchChallenge

protocol SearchChallengePresentable { }

final class SearchChallengeCoordinator: ViewableCoordinator<SearchChallengePresentable>, SearchChallengeCoordinatable {
  weak var listener: SearchChallengeListener?

  private let viewModel: SearchChallengeViewModel
  
  init(
    viewControllerable: ViewControllable,
    viewModel: SearchChallengeViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}
