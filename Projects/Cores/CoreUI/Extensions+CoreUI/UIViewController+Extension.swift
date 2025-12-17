//
//  UIViewController+Extension.swift
//  Core
//
//  Created by jung on 9/17/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

public extension UIViewController {
  func hideTabBar(animated: Bool) {
    guard
      self.tabBarController?.tabBar.isHidden == false,
      let tabBarHideY = self.tabBarHideY
    else { return }
    
    animated ? hideTabBarWithAnimation(tabBarY: tabBarHideY) : hideTabBar(tabBarY: tabBarHideY)
  }
  
  func showTabBar(animted: Bool) {
    guard
      self.tabBarController?.tabBar.isHidden == true,
      let tabBarPresentY = self.tabBarPresentY
    else { return }
    
    self.tabBarController?.tabBar.isHidden = false
    
    animted ? showTabBarWithAnimation(tabBarY: tabBarPresentY) : showTabBar(tabBarY: tabBarPresentY)
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
  
  func hideTabBar(tabBarY: CGFloat) {
    self.tabBarController?.tabBar.frame.origin.y = tabBarY
    self.tabBarController?.tabBar.isHidden = true
  }
  
  func hideTabBarWithAnimation(tabBarY: CGFloat) {
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveLinear
    ) {
      self.tabBarController?.tabBar.frame.origin.y = tabBarY
      self.view.layoutIfNeeded()
    } completion: { _ in
      self.tabBarController?.tabBar.isHidden = true
    }
  }
  
  func showTabBar(tabBarY: CGFloat) {
    self.tabBarController?.tabBar.frame.origin.y = tabBarY
    self.view.layoutIfNeeded()
  }
  
  func showTabBarWithAnimation(tabBarY: CGFloat) {
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
