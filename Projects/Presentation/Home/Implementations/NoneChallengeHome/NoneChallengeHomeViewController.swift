//
//  NoneChallengeHomeViewController.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

final class NoneChallengeHomeViewController: UIViewController {
  private let viewModel: NoneChallengeHomeViewModel
  
  init(viewModel: NoneChallengeHomeViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
