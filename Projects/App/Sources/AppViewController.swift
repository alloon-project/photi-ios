//
//  AppViewController.swift
//  Alloon-DEV
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class AppViewController: UITabBarController, ViewControllerable {
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    tabBar.frame.size.height = 64 + UIView.safeAreaInset.bottom
    tabBar.frame.origin.y = view.frame.height - tabBar.frame.size.height
    tabBar.itemPositioning = .centered
    tabBar.itemWidth = 46
    tabBar.itemSpacing = 67
  }
}

// MARK: - AppPresentable
extension AppViewController: AppPresentable {
  func attachNavigationControllers(_ navigationControllers: NavigationControllerable...) {
    let navigations = navigationControllers.map(\.navigationController)
    
    navigations.forEach {
      $0.interactivePopGestureRecognizer?.isEnabled = false
      $0.isNavigationBarHidden = true
    }
  
    setViewControllers(navigations, animated: false)
    setTapBarItems()
  }
  
  func changeNavigationControllerToHome() {
      selectedIndex = 0 // 첫 번째 탭으로 전환
  }
  
  func changeNavigationControllerToChallenge() {
      selectedIndex = 1 // 두 번째 탭으로 전환
  }
  
  func changeNavigationControllerToMyPage() {
    selectedIndex = 2 // 세 번째 탭으로 전환
  }
}

// MARK: - UI Methods
private extension AppViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    tabBar.backgroundColor = .white
    
    // tabBar Border Setting
    tabBar.layer.borderWidth = 1
    tabBar.layer.borderColor = UIColor.gray200.cgColor
    tabBar.layer.cornerRadius = 16
    
    // tabBar AttributedText Setting
    let appearance = UITabBarItem.appearance()
    let normalAttributes = NSAttributedString.attributes(font: .caption1Bold, color: .gray400)
    let selectedAttributes = NSAttributedString.attributes(font: .caption1Bold, color: .blue500)
    
    appearance.setTitleTextAttributes(normalAttributes, for: .normal)
    appearance.setTitleTextAttributes(selectedAttributes, for: .selected)
  }
  
  func setTapBarItems() {
    guard let items = tabBar.items, items.count == 3 else { return }
    items[0].selectedImage = .homeBlue.withRenderingMode(.alwaysOriginal)
    items[0].image = .homeGray400.withRenderingMode(.alwaysOriginal)
    items[0].title = "홈"
    
    items[1].selectedImage = .postitBlue.withRenderingMode(.alwaysOriginal)
    items[1].image = .postitGray400.withRenderingMode(.alwaysOriginal)
    items[1].title = "챌린지"
    
    items[2].selectedImage = .userBlue.withRenderingMode(.alwaysOriginal)
    items[2].image = .userGray400.withRenderingMode(.alwaysOriginal)
    items[2].title = "마이"
  }
}
