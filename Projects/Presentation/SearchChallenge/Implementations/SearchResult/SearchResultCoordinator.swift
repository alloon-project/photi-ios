//
//  SearchResultCoordinator.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

protocol SearchResultListener: AnyObject {
  func didTapBackButtonAtSearchResult()
}

protocol SearchResultPresentable {
  func attachViewControllerables(_ viewControllerables: ViewControllerable...)
}

final class SearchResultCoordinator: ViewableCoordinator<SearchResultPresentable> {
  weak var listener: SearchResultListener?

  private let viewModel: SearchResultViewModel
  
  private let challengeTitleReulstContainable: ChallengeTitleResultContainable
  private var challengeTitleReulstCoordinator: ViewableCoordinating?
  
  private let hashTagResultContainable: HashTagResultContainable
  private var hashTagResultCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: SearchResultViewModel,
    challengeTitleReulstContainable: ChallengeTitleResultContainable,
    hashTagResultContainable: HashTagResultContainable
  ) {
    self.viewModel = viewModel
    self.challengeTitleReulstContainable = challengeTitleReulstContainable
    self.hashTagResultContainable = hashTagResultContainable
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  override func start() {
    attachSegments()
  }
  
  private func attachSegments() {
    let challengeTitleReulst = challengeTitleReulstContainable.coordinator(listener: self)
    let hashTagResult = hashTagResultContainable.coordinator(listener: self)
    
    presenter.attachViewControllerables(
      challengeTitleReulst.viewControllerable,
      hashTagResult.viewControllerable
    )
    addChild(challengeTitleReulst)
    addChild(hashTagResult)
    self.challengeTitleReulstCoordinator = challengeTitleReulst
    self.hashTagResultCoordinator = hashTagResult
  }
}

// MARK: - SearchResultCoordinatable
extension SearchResultCoordinator: SearchResultCoordinatable {
  func didTapBackButton() {
    listener?.didTapBackButtonAtSearchResult()
  }
}

// MARK: - ChallengeTitleResultListener
extension SearchResultCoordinator: ChallengeTitleResultListener { }

// MARK: - HashTagResultListener
extension SearchResultCoordinator: HashTagResultListener { }
