//
//  LoggedInViewController.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit

final class LoggedInViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .blue
  }
  
  func attachNavigationControllers(_ navigationControllers: UINavigationController ...) {
    setViewControllers(navigationControllers, animated: false)
  }
}
