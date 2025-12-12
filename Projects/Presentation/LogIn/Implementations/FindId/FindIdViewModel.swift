//
//  FindIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import Entity
import UseCase

protocol FindIdCoordinatable: AnyObject {
  func isRequestSucceed()
  func didTapBackButton()
}

final class FindIdViewModel {
  weak var coordinator: FindIdCoordinatable?
  
  private var cancellables: Set<AnyCancellable> = []
  private let useCase: LogInUseCase
  private let successEmailVerificationSubject = PassthroughSubject<Void, Never>()
  private let notRegisteredEmailSubject = PassthroughSubject<Void, Never>()
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let email: AnyPublisher<String, Never>
    let endEditingUserEmail: AnyPublisher<Void, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
    let didAppearAlert: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let successEmailVerification: AnyPublisher<Void, Never>
    let notRegisteredEmail: AnyPublisher<Void, Never>
    let invalidFormat: AnyPublisher<Void, Never>
    let networkUnstable: AnyPublisher<Void, Never>
    let isEnabledConfirm: AnyPublisher<Bool, Never>
  }
  
  // MARK: - Initializers
  init(useCase: LogInUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)

    input.didTapNextButton
      .withLatestFrom(input.email)
      .sinkOnMain(with: self) { owner, email in
        Task { await owner.requestCheckEmail(email: email) }
      }.store(in: &cancellables)
    
    input.didAppearAlert
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.isRequestSucceed()
      }.store(in: &cancellables)

    let inValidateEmail = input.endEditingUserEmail
      .withLatestFrom(input.email)
      .filter { !$0.isValidateEmail() || $0.count > 100 }
      .map { _ in () }
    
    let isEnabledConfirm = input.email
       .map { $0.isValidateEmail() && $0.count <= 100 }

    return Output(
      successEmailVerification: successEmailVerificationSubject.eraseToAnyPublisher(),
      notRegisteredEmail: notRegisteredEmailSubject.eraseToAnyPublisher(),
      invalidFormat: inValidateEmail.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      isEnabledConfirm: isEnabledConfirm.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension FindIdViewModel {
  func requestCheckEmail(email: String) async {
    do {
      try await useCase.sendUserInformation(to: email)
      successEmailVerificationSubject.send(())
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    if let error = error as? APIError, case .userNotFound = error {
      notRegisteredEmailSubject.send(())
    } else {
      networkUnstableSubject.send(())
    }
  }
}
