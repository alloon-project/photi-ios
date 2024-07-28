//
//  SearchChallengeCoordinator.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import SearchChallenge

protocol SearchChallengeViewModelable { }

final class SearchChallengeCoordinator: Coordinator, SearchChallengeCoordinatable {
  weak var listener: SearchChallengeListener?
  
  private let viewController: SearchChallengeViewController
  private let viewModel: SearchChallengeViewModel
  
  init(viewModel: SearchChallengeViewModel) {
    self.viewModel = viewModel
    self.viewController = SearchChallengeViewController()
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
