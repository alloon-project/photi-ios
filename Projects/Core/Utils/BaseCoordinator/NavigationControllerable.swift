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

extension NavigationControllerable: ViewControllerable { }

public class NavigationControllerable {
  public let navigationController: UINavigationController
  
  /// 가장위에 있는 ViewControllable을 리턴합니다.
  public var topViewControllable: ViewControllerable {
    var top: ViewControllerable = self
    
    while
      let presented = getPresentedViewController(base: top.uiviewController) as? ViewControllerable {
      top = presented
    }
    
    return top
  }
  
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

// MARK: - Public Methods
public extension NavigationControllerable {
  func pushViewController(_ viewControllable: ViewControllerable, animated: Bool) {
    navigationController.pushViewController(viewControllable.uiviewController, animated: animated)
  }
  
  func popViewController(animated: Bool) {
    navigationController.popViewController(animated: animated)
  }
  
  func popToRoot(animated: Bool) {
    navigationController.popToRootViewController(animated: animated)
  }
  
  func setViewControllers(_ viewControllerables: [ViewControllerable]) {
    let uiviewControllers = viewControllerables.map(\.uiviewController)
    navigationController.setViewControllers(uiviewControllers, animated: true)
  }
}

// MARK: - Private Methods
private extension NavigationControllerable {
  func getPresentedViewController(base: UIViewController) -> UIViewController? {
    if let navigation = base as? UINavigationController {
      return navigation.visibleViewController
    } else if let tapBar = base as? UITabBarController {
      return tapBar.selectedViewController
    } else {
      return base.presentedViewController
    }
  }
}
