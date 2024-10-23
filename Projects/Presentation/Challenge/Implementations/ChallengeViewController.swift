//
//  ChallengeViewController.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

final class ChallengeViewController: UIViewController {
  private let viewModel: ChallengeViewModel
  
  // MARK: - Initializers
  init(viewModel: ChallengeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
