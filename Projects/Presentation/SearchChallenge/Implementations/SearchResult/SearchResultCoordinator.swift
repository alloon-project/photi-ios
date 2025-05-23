//
//  SearchResultCoordinator.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol SearchResultListener: AnyObject { }

protocol SearchResultPresentable { }

final class SearchResultCoordinator: ViewableCoordinator<SearchResultPresentable> {
  weak var listener: SearchResultListener?

  private let viewModel: SearchResultViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: SearchResultViewModel
  ) {
    self.viewModel = viewModel
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - SearchResultCoordinatable
extension SearchResultCoordinator: SearchResultCoordinatable { }
