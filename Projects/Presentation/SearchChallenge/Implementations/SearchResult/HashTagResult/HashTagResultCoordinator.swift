//
//  HashTagResultCoordinator.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol HashTagResultListener: AnyObject { }

protocol HashTagResultPresentable { }

final class HashTagResultCoordinator: ViewableCoordinator<HashTagResultPresentable> {
  weak var listener: HashTagResultListener?

  private let viewModel: HashTagResultViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: HashTagResultViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - HashTagResultCoordinatable
extension HashTagResultCoordinator: HashTagResultCoordinatable { }
