//
//  ViewControllerable.swift
//  Core
//
//  Created by jung on 1/6/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit

public protocol ViewControllerable: AnyObject {
  var uiviewController: UIViewController { get }
}

public extension ViewControllerable where Self: UIViewController {
  var uiviewController: UIViewController { return self }
}

// MARK: - Present Methods
public extension ViewControllerable {
  func present(
    _ viewControllable: ViewControllerable,
    animated: Bool,
    completion: (() -> Void)? = nil
  ) {
    self.uiviewController.present(
      viewControllable.uiviewController,
      animated: animated,
      completion: completion
    )
  }
  
  func present(
    _ viewControllable: ViewControllerable,
    animated: Bool,
    modalPresentationStyle: UIModalPresentationStyle,
    completion: (() -> Void)? = nil
  ) {
    viewControllable.uiviewController.modalPresentationStyle = modalPresentationStyle
    self.uiviewController.present(
      viewControllable.uiviewController,
      animated: animated,
      completion: completion
    )
  }
  
  func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
    self.uiviewController.dismiss(animated: animated, completion: completion)
  }
}

// MARK: - Push Methods
public extension ViewControllerable {
  func pushViewController(_ viewControllable: ViewControllerable, animated: Bool) {
    if let nav = self.uiviewController as? UINavigationController {
      nav.pushViewController(viewControllable.uiviewController, animated: animated)
    } else {
      self.uiviewController
        .navigationController?
        .pushViewController(viewControllable.uiviewController, animated: animated)
    }
  }
  
  func popViewController(animated: Bool) {
    if let nav = self.uiviewController as? UINavigationController {
      nav.popViewController(animated: animated)
    } else {
      self.uiviewController.navigationController?.popViewController(animated: animated)
    }
  }
  
  func popToRoot(animated: Bool) {
    if let nav = self.uiviewController as? UINavigationController {
      nav.popToRootViewController(animated: animated)
    } else {
      self.uiviewController.navigationController?.popToRootViewController(animated: animated)
    }
  }
  
  func setViewControllers(_ viewControllerables: [ViewControllerable]) {
    if let nav = self.uiviewController as? UINavigationController {
      nav.setViewControllers(viewControllerables.map(\.uiviewController), animated: true)
    } else {
      self.uiviewController
        .navigationController?
        .setViewControllers(
          viewControllerables.map(\.uiviewController),
          animated: true
        )
    }
  }
  
  /// 가장위에 있는 ViewControllable을 리턴합니다.
  var topViewControllable: ViewControllerable {
    var top: ViewControllerable = self
    
    while
      let presented = getPresentedViewController(base: top.uiviewController) as? ViewControllerable {
      top = presented
    }

    return top
  }
  
  private func getPresentedViewController(base: UIViewController) -> UIViewController? {
    if let navigation = base as? UINavigationController {
      return navigation.visibleViewController
    } else if let tapBar = base as? UITabBarController {
      return tapBar.selectedViewController
    } else {
      return base.presentedViewController
    }
  }
}
