//
//  MyPageCoordinator.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core
import MyPage

protocol MyPageViewModelable { }

final class MyPageCoordinator: Coordinator, MyPageCoordinatable {
  weak var listener: MyPageListener?
  
  private let viewController: MyPageViewController
  private let viewModel: MyPageViewModel
  
  private let settingContainable: SettingContainable
  private var settingCoordinator: Coordinating?
  
  private let endedChallengeContainable: EndedChallengeContainable
  private var endedChallengeCoordinator: Coordinating?
  
  init(
    viewModel: MyPageViewModel,
    settingContainable: SettingContainable,
    endedChallengeContainable: EndedChallengeContainable
  ) {
    self.viewModel = viewModel
    
    self.settingContainable = settingContainable
    self.endedChallengeContainable = endedChallengeContainable
    
    self.viewController = MyPageViewController(viewModel: viewModel)
    super.init()
    viewModel.coordinator = self
  }
  
  override func start(at navigationController: UINavigationController?) {
    super.start(at: navigationController)
    navigationController?.setNavigationBarHidden(true, animated: false)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  func attachSetting() {
    guard settingCoordinator == nil else { return }
    
    let coordinater = settingContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.settingCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachSetting() {
    guard let coordinator = settingCoordinator else { return }
    
    removeChild(coordinator)
    self.settingCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
  
  func attachAuthCountDetail() {
  }
  
  func detachAuthCountDetail() {
  }
  
  func attachEndedChallenge() {
    guard endedChallengeCoordinator == nil else { return }
    
    let coordinater = endedChallengeContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.endedChallengeCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachEndedChallenge() {
    guard let coordinator = endedChallengeCoordinator else { return }
    
    removeChild(coordinator)
    self.endedChallengeCoordinator = nil
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - SettingListener
extension MyPageCoordinator: SettingListener {
  func didTapBackButtonAtSetting() {
    detachSetting()
  }
}

// MARK: - FinishedListener
extension MyPageCoordinator: EndedChallengeListener {
  func didTapBackButtonAtEndedChallenge() {
    detachEndedChallenge()
  }
}
