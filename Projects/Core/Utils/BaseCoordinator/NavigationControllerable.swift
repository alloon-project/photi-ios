//
//  NavigationControllerable.swift
//  Core
//
//  Created by jung on 1/6/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit

public extension ViewControllerable where Self: NavigationControllerable {
  var uiviewController: UIViewController { return self.navigationController }
}

public class NavigationControllerable: ViewControllerable {
  public let navigationController: UINavigationController
  
  // MARK: - Initializers
  public init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  public init(_ rootViewControllerable: ViewControllerable) {
    self.navigationController = UINavigationController(rootViewController: rootViewControllerable.uiviewController)
  }
  
  public init() {
    self.navigationController = UINavigationController()
  }
}
