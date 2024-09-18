//
//  NoneMemberHomeViewController.swift
//  HomeImpl
//
//  Created by jung on 9/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

final class NoneMemberHomeViewController: UIViewController {
  private let viewModel: any NoneMemberHomeViewModelType
  
  // MARK: - Initializers
  init(viewModel: any NoneMemberHomeViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
