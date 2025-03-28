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
  
  private let FeedHistoryContainable: FeedHistoryContainable
  private var FeedHistoryCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: MyPageViewModel,
    settingContainable: SettingContainable,
    endedChallengeContainable: EndedChallengeContainable,
    FeedHistoryContainable: FeedHistoryContainable
  ) {
    self.viewModel = viewModel
    
    self.settingContainable = settingContainable
    self.endedChallengeContainable = endedChallengeContainable
    self.FeedHistoryContainable = FeedHistoryContainable
    
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
    viewControllerable.popToRoot(animated: true)
    self.settingCoordinator = nil
  }
  
  func attachFeedHistory(count: Int) {
    guard FeedHistoryCoordinator == nil else { return }
    
    let coordinator = FeedHistoryContainable.coordinator(listener: self, feedCount: count)
    addChild(coordinator)
    
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)

    self.FeedHistoryCoordinator = coordinator
  }
  
  func detachFeedHistory() {
    guard let coordinator = FeedHistoryCoordinator else { return }
    
    removeChild(coordinator)
    
    viewControllerable.popViewController(animated: true)
    self.FeedHistoryCoordinator = nil
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
  func isUserResigned() {
    detachSetting()
    listener?.isUserResigned()
  }
  
  func didTapBackButtonAtSetting() {
    detachSetting()
  }
}

// MARK: - ProofListener
extension MyPageCoordinator: FeedHistoryListener {
  func didTapBackButtonAtFeedHistory() {
    detachFeedHistory()
  }
}

// MARK: - FinishedListener
extension MyPageCoordinator: EndedChallengeListener {
  func didTapBackButtonAtEndedChallenge() {
    detachEndedChallenge()
  }
}
