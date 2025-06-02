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
  
  private let feedHistoryContainable: FeedHistoryContainable
  private var feedHistoryCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: MyPageViewModel,
    settingContainable: SettingContainable,
    endedChallengeContainable: EndedChallengeContainable,
    feedHistoryContainable: FeedHistoryContainable
  ) {
    self.viewModel = viewModel
    
    self.settingContainable = settingContainable
    self.endedChallengeContainable = endedChallengeContainable
    self.feedHistoryContainable = feedHistoryContainable
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - Setting
extension MyPageCoordinator {
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
}

// MARK: - FeedHistory
extension MyPageCoordinator {
  func attachFeedHistory(count: Int) {
    guard feedHistoryCoordinator == nil else { return }
    
    let coordinator = feedHistoryContainable.coordinator(listener: self, feedCount: count)
    addChild(coordinator)
    
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)

    self.feedHistoryCoordinator = coordinator
  }
  
  func detachFeedHistory() {
    guard let coordinator = feedHistoryCoordinator else { return }
    
    removeChild(coordinator)
    
    viewControllerable.popViewController(animated: true)
    self.feedHistoryCoordinator = nil
  }
}

// MARK: - EndedChallenge
extension MyPageCoordinator {
  func attachEndedChallenge(count: Int) {
    guard endedChallengeCoordinator == nil else { return }
    
    let coordinator = endedChallengeContainable.coordinator(endedChallengeCount: count, listener: self)
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

extension MyPageCoordinator: MyPageCoordinatable {
  func authenticatedFailed() {
    listener?.authenticatedFailedAtMyPage()
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

// MARK: - FeedHistoryListener
extension MyPageCoordinator: FeedHistoryListener {
  func authenticatedFailedAtFeedHistory() {
    listener?.authenticatedFailedAtMyPage()
  }
  
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
