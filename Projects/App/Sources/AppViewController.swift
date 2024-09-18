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

final class AppViewController: UITabBarController {
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
  
  // MARK: - attachNavigationControllers
  func attachNavigationControllers(_ navigationControllers: UINavigationController ...) {
    navigationControllers.forEach { $0.isNavigationBarHidden = true }
    setViewControllers(navigationControllers, animated: false)
    setTapBarItems()
  }
}

// MARK: - UI Methods
private extension AppViewController {
  func setupUI() {
    self.view.backgroundColor = .white
    tabBar.backgroundColor = .white
    tabBar.tintColor = .blue400
    tabBar.unselectedItemTintColor = .gray400
    
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
    // TODO: - Image DS적용 후 일괄 수정
    items[0].image = UIImage(systemName: "house.fill")!
    items[0].title = "홈"
    
    items[1].image = UIImage(systemName: "globe.asia.australia.fill")!
    items[1].title = "챌린지"
    
    items[2].image = UIImage(systemName: "person.crop.circle.fill")!
    items[2].title = "프로필"
  }
}
