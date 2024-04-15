//
//  LoggedInCoordinator.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol LoggedInListener: AnyObject { }

final class LoggedInCoordinator: Coordinater {
  weak var listener: LoggedInListener?
  
  private let viewController: LoggedInViewController
  
  override init() {
    self.viewController = LoggedInViewController()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
  }
}
