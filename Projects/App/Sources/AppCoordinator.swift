//
//  AppCoordinator.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

final class AppCoordinator: Coordinater {
  override func start(at navigationController: UINavigationController) {
    super.start(at: navigationController)
    
    navigationController.pushViewController(AppViewController(), animated: true)
  }
}
