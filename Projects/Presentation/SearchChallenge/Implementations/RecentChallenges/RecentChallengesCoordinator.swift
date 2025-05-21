//
//  RecentChallengesCoordinator.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol RecentChallengesListener: AnyObject { }

protocol RecentChallengesPresentable { }

final class RecentChallengesCoordinator: ViewableCoordinator<RecentChallengesPresentable> {
  weak var listener: RecentChallengesListener?

  private let viewModel: RecentChallengesViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: RecentChallengesViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - RecentChallengesCoordinatable
extension RecentChallengesCoordinator: RecentChallengesCoordinatable { }
