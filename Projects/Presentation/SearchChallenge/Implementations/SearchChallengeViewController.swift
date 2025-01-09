//
//  SearchChallengeViewController.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

final class SearchChallengeViewController: UIViewController, ViewControllerable {
  private let viewModel: SearchChallengeViewModel
  
  init(viewModel: SearchChallengeViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - SearchChallengePresentable
extension SearchChallengeViewController: SearchChallengePresentable { }
