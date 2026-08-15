//
//  AppViewModel.swift
//  DTO
//
//  Created by jung on 6/1/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import UseCase

protocol AppCoordinatable: AnyObject {
  func shouldReloadAllPage()
  func attachLogIn()
  func handleDeepLink(challengeId: Int)
}

protocol AppViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: AppCoordinatable? { get set }
}

final class AppViewModel: AppViewModelType {
  weak var coordinator: AppCoordinatable?
  private let useCase: AppUseCase
  private var cancellables = Set<AnyCancellable>()

  private let allowMoveToMyPage = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapMyPageTabBarItem: AnyPublisher<Void, Never>
    let didTapLogInButton: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let allowMoveToMyPage: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: AppUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapMyPageTabBarItem
      .sink(with: self) { owner, _ in
        owner.handleMyPageTabSelection()
      }.store(in: &cancellables)
    
    input.didTapLogInButton
      .sink(with: self) { owner, _ in
        owner.coordinator?.attachLogIn()
      }.store(in: &cancellables)
    
    return Output(allowMoveToMyPage: allowMoveToMyPage.eraseToAnyPublisher())
  }
}

// MARK: - Private Methods
private extension AppViewModel {
  func handleMyPageTabSelection() {
    Task {
      let isLogin = await useCase.isLogIn()

      isLogin ? allowMoveToMyPage.send(()) : coordinator?.shouldReloadAllPage()
    }
  }
}
