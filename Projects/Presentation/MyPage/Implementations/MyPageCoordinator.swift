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
  
  private let proofChallengeContainable: ProofChallengeContainable
  private var proofChallengeCoordinator: Coordinating?
  
  init(
    viewModel: MyPageViewModel,
    settingContainable: SettingContainable,
    endedChallengeContainable: EndedChallengeContainable,
    proofChallengeContainable: ProofChallengeContainable
  ) {
    self.viewModel = viewModel
    
    self.settingContainable = settingContainable
    self.endedChallengeContainable = endedChallengeContainable
    self.proofChallengeContainable = proofChallengeContainable
    
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
  
  func attachProofChallenge() {
    guard proofChallengeCoordinator == nil else { return }
    
    let coordinater = proofChallengeContainable.coordinator(listener: self)
    addChild(coordinater)
    
    self.proofChallengeCoordinator = coordinater
    coordinater.start(at: self.navigationController)
  }
  
  func detachProofChallenge() {
    guard let coordinator = proofChallengeCoordinator else { return }
    
    removeChild(coordinator)
    self.proofChallengeCoordinator = nil
    navigationController?.popViewController(animated: true)
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

// MARK: - ProofListener
extension MyPageCoordinator: ProofChallengeListener {
  func didTapBackButtonAtProofChallenge() {
    detachProofChallenge()
  }
}

// MARK: - FinishedListener
extension MyPageCoordinator: EndedChallengeListener {
  func didTapBackButtonAtEndedChallenge() {
    detachEndedChallenge()
  }
}
