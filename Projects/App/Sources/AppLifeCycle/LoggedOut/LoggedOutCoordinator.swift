//
//  LoggedOutCoordinator.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

protocol LoggedOutListener: AnyObject {
  func didFinishLoggedOut()
}

final class LoggedOutCoordinator: Coordinator {
  weak var listener: LoggedOutListener?
  
  private let viewController: LoggedOutViewController
  
  override init() {
    self.viewController = LoggedOutViewController()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  override func stop() {
    super.stop()
    listener?.didFinishLoggedOut()
  }
}
