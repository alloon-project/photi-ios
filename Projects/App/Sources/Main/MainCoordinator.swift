//
//  MainCoordinator.swift
//  Alloon-DEV
//
//  Created by jung on 4/15/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import Home
import MyMission
import MyPage

protocol MainListener: AnyObject { }

final class MainCoordinator: Coordinator {
  weak var listener: MainListener?
  
  private let viewController: MainViewController
  
  private let homeNavigationController = UINavigationController()
  private let myMissionNavigationController = UINavigationController()
  private let myPageNavigationController = UINavigationController()
  
  private let homeContainable: HomeContainable
  private let myMissionContainable: MyMissionContainable
  private let myPageContainable: MyPageContainable
  
  init(
    homeContainable: HomeContainable,
    myMissionContainable: MyMissionContainable,
    myPageContainable: MyPageContainable
  ) {
    self.homeContainable = homeContainable
    self.myMissionContainable = myMissionContainable
    self.myPageContainable = myPageContainable
    self.viewController = MainViewController()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.pushViewController(viewController, animated: false)
    attachCoordinators()
  }
  
  func attachCoordinators() {
    let homeCoordinator = homeContainable.coordinator(listener: self)
    let myMissionCoordinator = myMissionContainable.coordinator(listener: self)
    let myPageCoordinator = myPageContainable.coordinator(listener: self)
    
    homeCoordinator.start(at: homeNavigationController)
    myMissionCoordinator.start(at: myMissionNavigationController)
    myPageCoordinator.start(at: myPageNavigationController)
    
    viewController.attachNavigationControllers(
      homeNavigationController,
      myMissionNavigationController,
      myPageNavigationController
    )
  }
}

// MARK: - HomeListener
extension MainCoordinator: HomeListener { }

// MARK: - MyMissionListener
extension MainCoordinator: MyMissionListener { }

// MARK: - MyPageListener
extension MainCoordinator: MyPageListener { }
