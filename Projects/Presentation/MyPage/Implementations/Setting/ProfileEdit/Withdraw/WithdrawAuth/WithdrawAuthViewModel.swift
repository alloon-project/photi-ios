//
//  WithdrawAuthViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 2/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import CoreUI
import Foundation

import Entity
import UseCase

protocol WithdrawAuthCoordinatable: AnyObject {
  func withdrawalSucceed()
  func didTapBackButton()
  func authenticatedFailed()
}

protocol WithdrawAuthViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var cancellables: Set<AnyCancellable> { get set }
  var coordinator: WithdrawAuthCoordinatable? { get set }
}

final class WithdrawAuthViewModel: WithdrawAuthViewModelType {
  private var cancellables = Set<AnyCancellable>()
  
  weak var coordinator: WithdrawAuthCoordinatable?
  
  private let useCase: ProfileEditUseCase
  private let didFailPasswordVerificationRelay = PassthroughSubject<Void, Never>()
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let password: AnyPublisher<String, Never>
    let didTapWithdrawButton: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let didFailPasswordVerification: AnyPublisher<Void, Never>
    let networkUnstable: AnyPublisher<Void, Never>
    let isEnabledWithdrawButton: AnyPublisher<Bool, Never>
  }
  
  // MARK: - Initializers
  init(useCase: ProfileEditUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)
    
    let isEnabledWithdrawButton = input.password.map { $0.isValidPassword }
    
    input.didTapWithdrawButton
      .withLatestFrom(input.password)
      .sinkOnMain(with: self) { owner, password in
        Task { await owner.withdraw(password: password) }
      }
      .store(in: &cancellables)
    
    return Output(
      didFailPasswordVerification: didFailPasswordVerificationRelay.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher(),
      isEnabledWithdrawButton: isEnabledWithdrawButton.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension WithdrawAuthViewModel {
  @MainActor func withdraw(password: String) async {
    do {
      try await useCase.withdraw(with: .password(password))
      coordinator?.withdrawalSucceed()
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.send(()) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .myPageFailed(reason) where reason == .loginUnAuthenticated:
        didFailPasswordVerificationRelay.send(())
      case let .myPageFailed(reason) where reason == .userNotFound:
        coordinator?.authenticatedFailed()
      default:
        networkUnstableRelay.send(())
    }
  }
}
