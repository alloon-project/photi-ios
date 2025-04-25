//
//  ChallengeHomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Challenge
import Core

protocol ChallengeHomeListener: AnyObject {
  func requestLogInAtChallengeHome()
}

protocol ChallengeHomePresentable { }

final class ChallengeHomeCoordinator: ViewableCoordinator<ChallengeHomePresentable>, ChallengeHomeCoordinatable {
  weak var listener: ChallengeHomeListener?

  private let viewModel: ChallengeHomeViewModel
  
  private let challengeContainer: ChallengeContainable
  private var challengeCoordinator: ViewableCoordinating?
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ChallengeHomeViewModel,
    challengeContainer: ChallengeContainable
  ) {
    self.viewModel = viewModel
    self.challengeContainer = challengeContainer 
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
  
  func requestLogIn() {
    listener?.requestLogInAtChallengeHome()
  }
}

// MARK: - Challenge
extension ChallengeHomeCoordinator {
  func attachChallenge(id: Int) {
    guard challengeCoordinator == nil else { return }
    
    let coordinator = challengeContainer.coordinator(listener: self, challengeId: id)
    addChild(coordinator)
    viewControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    
    self.challengeCoordinator = coordinator
  }
  
  func detachChallenge() {
    guard let coordinator = challengeCoordinator else { return }
    
    removeChild(coordinator)
    viewControllerable.popViewController(animated: true)
    viewControllerable.uiviewController.showTabBar(animted: true)
    self.challengeCoordinator = nil
  }
}

// MARK: - ChallengeListener
extension ChallengeHomeCoordinator: ChallengeListener {
  func didTapBackButtonAtChallenge() {
    detachChallenge()
  }
  
  func shouldDismissChallenge() {
    detachChallenge()
  }
  
  // 이거 제대로 삭제되는지 확인해봐야겠다~!
  
  func leaveChallenge(isDelete: Bool) { }
}
