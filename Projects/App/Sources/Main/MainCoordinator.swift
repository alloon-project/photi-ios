//
//  MainCoordinator.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol MainListener: AnyObject { }

final class MainCoordinator: Coordinator {
  weak var listener: MainListener?
  
  private let viewController: MainViewController
  
  override init() {
    self.viewController = MainViewController()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
