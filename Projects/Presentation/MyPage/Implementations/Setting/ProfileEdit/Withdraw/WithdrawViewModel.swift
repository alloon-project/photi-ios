//
//  WithdrawViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Combine
import Core
import Entity
import UseCase

protocol WithdrawCoordinatable: AnyObject {
  @MainActor func attachWithdrawAuth()
  func didTapBackButton()
  func didTapCancelButton()
  func withdrawalSucceed()
  func authenticatedFailed()
}

protocol WithdrawViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var cancellables: Set<AnyCancellable> { get }
  var coordinator: WithdrawCoordinatable? { get set }
}

final class WithdrawViewModel: WithdrawViewModelType {
  var cancellables = Set<AnyCancellable>()

  weak var coordinator: WithdrawCoordinatable?

  private let useCase: ProfileEditUseCase
  private let showOAuthAlertSubject = PassthroughSubject<String, Never>()
  private let requestAppleAuthorizationSubject = PassthroughSubject<Void, Never>()
  private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapWithdrawButton: AnyPublisher<Void, Never>
    let didTapCancelButton: AnyPublisher<Void, Never>
    let didConfirmOAuthWithdraw: AnyPublisher<Void, Never>
    let appleAuthorizationCode: AnyPublisher<String, Never>
    let appleAuthorizationFailed: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let showOAuthAlert: AnyPublisher<String, Never>
    let requestAppleAuthorization: AnyPublisher<Void, Never>
    let isLoading: AnyPublisher<Bool, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }

  // MARK: - Initializers
  init(useCase: ProfileEditUseCase) {
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sink { [weak self] in
        self?.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)

    input.didTapWithdrawButton
      .sink { [weak self] in
        guard let self else { return }
        let providerString = ServiceConfiguration.shared.authProvider
        let provider = AuthProvider(rawValue: providerString) ?? .normal
        Task {
          if provider == .normal {
            await self.coordinator?.attachWithdrawAuth()
          } else {
            self.showOAuthAlertSubject.send(self.providerDisplayName(provider))
          }
        }
      }
      .store(in: &cancellables)

    input.didTapCancelButton
      .sink { [weak self] in
        self?.coordinator?.didTapCancelButton()
      }
      .store(in: &cancellables)

    input.didConfirmOAuthWithdraw
      .sink { [weak self] in
        guard let self else { return }
        let providerString = ServiceConfiguration.shared.authProvider
        let provider = AuthProvider(rawValue: providerString) ?? .normal
        if provider == .apple {
          self.requestAppleAuthorizationSubject.send(())
        } else {
          Task { await self.withdrawOAuth(provider: provider) }
        }
      }
      .store(in: &cancellables)

    bindAppleAuthorization(input: input)

    return Output(
      showOAuthAlert: showOAuthAlertSubject.eraseToAnyPublisher(),
      requestAppleAuthorization: requestAppleAuthorizationSubject.eraseToAnyPublisher(),
      isLoading: isLoadingSubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Bind Methods
private extension WithdrawViewModel {
  func bindAppleAuthorization(input: Input) {
    input.appleAuthorizationCode
      .sink { [weak self] authorizationCode in
        Task { await self?.withdrawApple(authorizationCode: authorizationCode) }
      }
      .store(in: &cancellables)

    input.appleAuthorizationFailed
      .sink { [weak self] in
        self?.networkUnstableSubject.send(())
      }
      .store(in: &cancellables)
  }
}

// MARK: - Private Methods
private extension WithdrawViewModel {
  func providerDisplayName(_ provider: AuthProvider) -> String {
    switch provider {
    case .kakao: return "카카오"
    case .google: return "구글"
    case .apple: return "애플"
    case .normal: return ""
    }
  }

  @MainActor
  func withdrawOAuth(provider: AuthProvider) async {
    defer { isLoadingSubject.send(false) }

    isLoadingSubject.send(true)

    do {
      switch provider {
      case .kakao:
        try await useCase.withdraw(with: .kakao)
      case .google:
        try await useCase.withdraw(with: .google)
      case .apple, .normal:
        throw APIError.serverError
      }
      coordinator?.withdrawalSucceed()
    } catch {
      isLoadingSubject.send(false)
      handleError(error)
    }
  }

  @MainActor
  func withdrawApple(authorizationCode: String) async {
    defer { isLoadingSubject.send(false) }

    isLoadingSubject.send(true)

    do {
      try await useCase.withdraw(with: .apple(authorizationCode: authorizationCode))
      coordinator?.withdrawalSucceed()
    } catch {
      handleError(error)
    }
  }

  func handleError(_ error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableSubject.send(())
    }

    switch error {
    case .authenticationFailed, .userNotFound:
      coordinator?.authenticatedFailed()
    default:
      networkUnstableSubject.send(())
    }
  }
}
