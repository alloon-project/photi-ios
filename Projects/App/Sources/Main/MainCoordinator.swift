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
import SearchChallenge
import MyPage

protocol MainListener: AnyObject { }

final class MainCoordinator: Coordinator {
  weak var listener: MainListener?
  
  private let viewController: MainViewController
  
  private let homeNavigationController = UINavigationController()
  private let searchChallengeNavigationController = UINavigationController()
  private let myPageNavigationController = UINavigationController()
  
  private let homeContainable: HomeContainable
  private var homeCoordinator: Coordinating?

  private let searchChallengeContainable: SearchChallengeContainable
  private var searchChallengeCoordinator: Coordinating?

  private let myPageContainable: MyPageContainable
  private var myPageCoordinator: Coordinating?

  init(
    homeContainable: HomeContainable,
    searchChallengeContainable: SearchChallengeContainable,
    myPageContainable: MyPageContainable
  ) {
    self.homeContainable = homeContainable
    self.searchChallengeContainable = searchChallengeContainable
    self.myPageContainable = myPageContainable
    self.viewController = MainViewController()
    super.init()
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.setNavigationBarHidden(true, animated: false)
    navigationController?.pushViewController(viewController, animated: false)
    attachCoordinators()
  }
  
  func attachCoordinators() {
    self.homeCoordinator = homeContainable.coordinator(listener: self)
    self.searchChallengeCoordinator = searchChallengeContainable.coordinator(listener: self)
    self.myPageCoordinator = myPageContainable.coordinator(listener: self)
    
    homeCoordinator?.start(at: homeNavigationController)
    searchChallengeCoordinator?.start(at: searchChallengeNavigationController)
    myPageCoordinator?.start(at: myPageNavigationController)
    
    viewController.attachNavigationControllers(
      homeNavigationController,
      searchChallengeNavigationController,
      myPageNavigationController
    )
  }
}

// MARK: - HomeListener
extension MainCoordinator: HomeListener { }

// MARK: - SearchChallengeListener
extension MainCoordinator: SearchChallengeListener { }

// MARK: - MyPageListener
extension MainCoordinator: MyPageListener { }
