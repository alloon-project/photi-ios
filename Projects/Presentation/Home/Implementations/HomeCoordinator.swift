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
import LogIn
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
  
  private let loginContainer: LogInContainable
  private var loginCoordinator: ViewableCoordinating?
  
  init(
    useCase: HomeUseCase,
    navigationControllerable: NavigationControllerable,
    loginContainer: LogInContainable,
    challengeHomeContainer: ChallengeHomeContainable,
    noneMemberHomeContainer: NoneMemberHomeContainable,
    noneChallengeHomeContainer: NoneChallengeHomeContainable
  ) {
    self.useCase = useCase
    self.navigationControllerable = navigationControllerable
    self.loginContainer = loginContainer
    self.challengeHomeContainer = challengeHomeContainer
    self.noneMemberHomeContainer = noneMemberHomeContainer
    self.noneChallengeHomeContainer = noneChallengeHomeContainer
    super.init()
  }
  
  override func start() {
    Task { await attachInitialScreenIfNeeded() }
  }
}

// MARK: - ChallengeHome
private extension HomeCoordinator {
  @MainActor func attachChallengeHome() {
    guard challengeHomeCoordinator == nil else { return }
    
    let coordinator = challengeHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationControllerable.setViewControllers([coordinator.viewControllerable])
    
    self.noneChallengeHomeCoordinator = coordinator
  }
  
  @MainActor func detachChallengeHome() {
    guard let coordinator = noneChallengeHomeCoordinator else { return }
    
    removeChild(coordinator)
    navigationControllerable.popViewController(animated: false)
    self.noneChallengeHomeCoordinator = nil
  }
}

// MARK: - NoneChallengeHome
private extension HomeCoordinator {
  @MainActor func attachNoneChallengeHome() {
    guard noneChallengeHomeCoordinator == nil else { return }
    
    let coordinator = noneChallengeHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationControllerable.setViewControllers([coordinator.viewControllerable])
    
    self.noneChallengeHomeCoordinator = coordinator
  }
  
  @MainActor func detachNoneChallengeHome() {
    guard let coordinator = noneChallengeHomeCoordinator else { return }
    
    removeChild(coordinator)
    coordinator.viewControllerable.dismiss()
    self.noneChallengeHomeCoordinator = nil
  }
}

// MARK: - NoneMemberHome
private extension HomeCoordinator {
  @MainActor func attachNoneMemberHome() {
    guard noneMemberHomeCoordinator == nil else { return }
    let coordinator = noneMemberHomeContainer.coordinator(listener: self)
    addChild(coordinator)
    
    navigationControllerable.setViewControllers([coordinator.viewControllerable])
    
    self.noneMemberHomeCoordinator = coordinator
  }
  
  @MainActor func detachNoneMemberHome() {
    guard let coordinator = noneMemberHomeCoordinator else { return }
    
    removeChild(coordinator)
    navigationControllerable.popViewController(animated: false)
    self.noneMemberHomeCoordinator = nil
  }
}

// MARK: - LogIn
private extension HomeCoordinator {
  @MainActor func attachLogIn() {
    guard loginCoordinator == nil else { return }
    
    let coordinator = loginContainer.coordinator(listener: self)
    addChild(coordinator)
    navigationControllerable.navigationController.hideTabBar(animated: true)
    navigationControllerable.pushViewController(coordinator.viewControllerable, animated: true)
    self.loginCoordinator = coordinator
  }
  
  @MainActor func detachLogIn() {
    guard let coordinator = loginCoordinator else { return }
    
    removeChild(coordinator)
    self.loginCoordinator = nil
    
    navigationControllerable.navigationController.showTabBar(animted: true)
    navigationControllerable.popViewController(animated: true)
  }
}

// MARK: - ChallengeHome Listener
extension HomeCoordinator: ChallengeHomeListener { }

// MARK: - NoneMemberHome Listener
extension HomeCoordinator: NoneMemberHomeListener {
  func didTapLogInButtonAtNoneMemberHome() {
    Task { await attachLogIn() }
  }
}

// MARK: - NoneChallengeHomeListener
extension HomeCoordinator: NoneChallengeHomeListener { }

// MARK: - LogInListener
extension HomeCoordinator: LogInListener {
  func didTapBackButtonAtLogIn() {
    Task { await detachLogIn() }
  }
  
  // TODO: 어디로 넘어갈지 판별 필요
  func didFinishLogIn(userName: String) {
    Task { await detachLogIn() }
  }
}

// MARK: - Private Methods
private extension HomeCoordinator {
  func attachInitialScreenIfNeeded() async {
    do {
      let count = try await useCase.challengeCount()

      count == 0 ? await attachNoneChallengeHome() : await attachChallengeHome()
    } catch {
      if let error = error as? APIError, case .authenticationFailed = error {
        await attachNoneMemberHome()
      } else {
        await presentNetworkUnstableAlert()
      }
    }
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
