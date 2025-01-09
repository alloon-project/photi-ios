//
//  MyPageCoordinator.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import MyPage

protocol MyPagePresentable { }

final class MyPageCoordinator: ViewableCoordinator<MyPagePresentable> {
  weak var listener: MyPageListener?

  private let viewModel: MyPageViewModel
  
  private let settingContainable: SettingContainable
  private var settingCoordinator: ViewableCoordinating?
  
  private let endedChallengeContainable: EndedChallengeContainable
  private var endedChallengeCoordinator: ViewableCoordinating?
  
  private let proofChallengeContainable: ProofChallengeContainable
  private var proofChallengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllable,
    viewModel: MyPageViewModel,
    settingContainable: SettingContainable,
    endedChallengeContainable: EndedChallengeContainable,
    proofChallengeContainable: ProofChallengeContainable
  ) {
    self.viewModel = viewModel
    
    self.settingContainable = settingContainable
    self.endedChallengeContainable = endedChallengeContainable
    self.proofChallengeContainable = proofChallengeContainable
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

extension MyPageCoordinator: MyPageCoordinatable {
  func attachSetting() {
    guard settingCoordinator == nil else { return }
    
    let coordinator = settingContainable.coordinator(listener: self)
    addChild(coordinator)
    
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.settingCoordinator = coordinator
  }
  
  func detachSetting() {
    guard let coordinator = settingCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.settingCoordinator = nil
  }
  
  func attachProofChallenge() {
    guard proofChallengeCoordinator == nil else { return }
    
    let coordinator = proofChallengeContainable.coordinator(listener: self)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)

    self.proofChallengeCoordinator = coordinator
  }
  
  func detachProofChallenge() {
    guard let coordinator = proofChallengeCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.proofChallengeCoordinator = nil
  }
  
  func attachEndedChallenge() {
    guard endedChallengeCoordinator == nil else { return }
    
    let coordinator = endedChallengeContainable.coordinator(listener: self)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.endedChallengeCoordinator = coordinator
  }
  
  func detachEndedChallenge() {
    guard let coordinator = endedChallengeCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    self.endedChallengeCoordinator = nil
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
