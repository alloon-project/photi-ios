//
//  HomeCoordinator.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxSwift
import Core
import Entity
import Home
import UseCase

final class HomeCoordinator: Coordinator {
  weak var listener: HomeListener?
  private let disposeBag = DisposeBag()
  private let useCase: HomeUseCase
  
  private let navigationControllerable: NavigationControllerable
  private let challengeHomeContainer: ChallengeHomeContainable
  private var challengeHomeCoordinator: ViewableCoordinating?
  
  private let noneMemberHomeContainer: NoneMemberHomeContainable
  private var noneMemberHomeCoordinator: ViewableCoordinating?
  
  private let noneChallengeHomeContainer: NoneChallengeHomeContainable
  private var noneChallengeHomeCoordinator: ViewableCoordinating?
  
  init(
    useCase: HomeUseCase,
    navigationControllerable: NavigationControllerable,
    challengeHomeContainer: ChallengeHomeContainable,
    noneMemberHomeContainer: NoneMemberHomeContainable,
    noneChallengeHomeContainer: NoneChallengeHomeContainable
  ) {
    self.useCase = useCase
    self.navigationControllerable = navigationControllerable
    self.challengeHomeContainer = challengeHomeContainer
    self.noneMemberHomeContainer = noneMemberHomeContainer
    self.noneChallengeHomeContainer = noneChallengeHomeContainer
    super.init()
  }
  
  override func start() {
    Task {
      await detachAll()
      await attachInitialScreenIfNeeded(animated: false)
    }
  }
}

// MARK: - ChallengeHome
private extension HomeCoordinator {
  @MainActor func attachChallengeHome(animated: Bool = true) {
    guard challengeHomeCoordinator == nil else { return }
    
    let coordinator = challengeHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationControllerable.setViewControllers([coordinator.viewControllerable], animated: animated)
    
    self.noneChallengeHomeCoordinator = coordinator
  }
  
  @MainActor func detachChallengeHome() {
    guard let coordinator = noneChallengeHomeCoordinator else { return }
    
    removeChild(coordinator)
    self.noneChallengeHomeCoordinator = nil
  }
}

// MARK: - NoneChallengeHome
private extension HomeCoordinator {
  @MainActor func attachNoneChallengeHome(animated: Bool = true) {
    guard noneChallengeHomeCoordinator == nil else { return }
    
    let coordinator = noneChallengeHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationControllerable.setViewControllers([coordinator.viewControllerable], animated: animated)
    
    self.noneChallengeHomeCoordinator = coordinator
  }
  
  @MainActor func detachNoneChallengeHome() {
    guard let coordinator = noneChallengeHomeCoordinator else { return }
    
    removeChild(coordinator)
    self.noneChallengeHomeCoordinator = nil
  }
}

// MARK: - NoneMemberHome
private extension HomeCoordinator {
  @MainActor func attachNoneMemberHome(animated: Bool = true) {
    guard noneMemberHomeCoordinator == nil else { return }
    let coordinator = noneMemberHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    
    navigationControllerable.setViewControllers([coordinator.viewControllerable], animated: animated)
    self.noneMemberHomeCoordinator = coordinator
  }
  
  @MainActor func detachNoneMemberHome() {
    guard let coordinator = noneMemberHomeCoordinator else { return }
    
    removeChild(coordinator)
    self.noneMemberHomeCoordinator = nil
  }
}

// MARK: - ChallengeHome Listener
extension HomeCoordinator: ChallengeHomeListener {
  func authenticatedFailedAtChallengeHome() {
    listener?.authenticatedFailedAtHome()
  }
  
  func requestNoneChallengeHomeAtChallengeHome() {
    Task {
      await detachChallengeHome()
      await attachNoneChallengeHome()
    }
  }
}

// MARK: - NoneMemberHome Listener
extension HomeCoordinator: NoneMemberHomeListener {
  func requestLogInAtNoneMemberHome() {
    listener?.requestLogInAtHome()
  }
}

// MARK: - NoneChallengeHomeListener
extension HomeCoordinator: NoneChallengeHomeListener {
  func authenticatedFailedAtNoneChallengeHome() {
    listener?.authenticatedFailedAtHome()
  }

  func requstConvertInitialHome() {
    navigationControllerable.navigationController.showTabBar(animted: true)
    Task {
      await detachNoneChallengeHome()
      await attachInitialScreenIfNeeded()
    }
  }
}

// MARK: - Private Methods
private extension HomeCoordinator {
  func attachInitialScreenIfNeeded(animated: Bool = true) async {
    do {
      let count = try await useCase.challengeCount()
      
      count == 0 ? await attachNoneChallengeHome(animated: animated) : await attachChallengeHome(animated: animated)
    } catch {
      if let error = error as? APIError, case .authenticationFailed = error {
        await attachNoneMemberHome(animated: animated)
      } else {
        await presentNetworkUnstableAlert()
      }
    }
  }
  
  func detachAll() async {
    await detachChallengeHome()
    await detachNoneMemberHome()
    await detachNoneChallengeHome()
  }
  
  @MainActor func presentNetworkUnstableAlert() {
    let alert = navigationControllerable.navigationController.presentNetworkUnstableAlert()
    
    alert.rx.didTapConfirmButton
      .subscribe(with: self) { owner, _ in
        Task { await owner.attachInitialScreenIfNeeded() }
      }
      .disposed(by: disposeBag)
  }
}
