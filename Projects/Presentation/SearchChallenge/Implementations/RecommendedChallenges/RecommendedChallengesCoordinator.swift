//
//  RecommendedChallengesCoordinator.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol RecommendedChallengesListener: AnyObject { }

protocol RecommendedChallengesPresentable { }

final class RecommendedChallengesCoordinator: ViewableCoordinator<RecommendedChallengesPresentable> {
  weak var listener: RecommendedChallengesListener?

  private let viewModel: RecommendedChallengesViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: RecommendedChallengesViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - RecommendedChallengesCoordinatable
extension RecommendedChallengesCoordinator: RecommendedChallengesCoordinatable { }
