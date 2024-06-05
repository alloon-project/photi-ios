//
//  EnterPasswordViewController.swift
//  LogInImpl
//
//  Created by jung on 6/5/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

final class EnterPasswordViewController: UIViewController {
  private let viewModel: EnterPasswordViewModel
  
  // MARK: - Initializers
  init(viewModel: EnterPasswordViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
