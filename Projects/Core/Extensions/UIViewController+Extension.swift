//
//  UIViewController+Extension.swift
//  Core
//
//  Created by jung on 9/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public extension UIViewController {
  func hideTabBar() {
    guard self.tabBarController?.tabBar.isHidden == false else { return }
    
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveLinear
    ) {
      guard let tabBarHideY = self.tabBarHideY else { return }
      self.tabBarController?.tabBar.frame.origin.y = tabBarHideY
      self.view.layoutIfNeeded()
    } completion: { _ in
      self.tabBarController?.tabBar.isHidden = true
    }
  }
  
  func showTabBar() {
    guard self.tabBarController?.tabBar.isHidden == true else { return }
    
    self.tabBarController?.tabBar.isHidden = false
    self.tabBarController?.tabBar.frame.origin.y = tabBarHideY ?? 0
    
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveLinear
    ) {
      guard let tabBarPresentY = self.tabBarPresentY else { return }
      
      self.tabBarController?.tabBar.frame.origin.y = tabBarPresentY
      self.view.layoutIfNeeded()
    }
  }
}

private extension UIViewController {
  var tabBarHideY: CGFloat? {
    guard let tabBarFrame = self.tabBarController?.tabBar.frame else { return nil }
    
    return view.frame.maxY + tabBarFrame.height
  }
  
  var tabBarPresentY: CGFloat? {
    guard let tabBarFrame = self.tabBarController?.tabBar.frame else { return nil }
    
    return view.frame.maxY - tabBarFrame.height
  }
}
