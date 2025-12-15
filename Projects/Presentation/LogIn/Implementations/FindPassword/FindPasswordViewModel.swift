//
//  FindPasswordViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import Core
import Entity
import UseCase

protocol FindPasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func attachResetPassword(userEmail: String, userName: String)
}

final class FindPasswordViewModel {
  weak var coordinator: FindPasswordCoordinatable?
  
  private var cancellables = Set<AnyCancellable>()
  private let useCase: LogInUseCase
  private let unMatchedIdOrEmailSubject = PassthroughSubject<Void, Never>()
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let userId: AnyPublisher<String, Never>
    let endEditingUserId: AnyPublisher<Void, Never>
    let userEmail: AnyPublisher<String, Never>
    let endEditingUserEmail: AnyPublisher<Void, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let inValidIdFormat: AnyPublisher<Void, Never>
    let inValidEmailFormat: AnyPublisher<Void, Never>
    let isEnabledNextButton: AnyPublisher<Bool, Never>
    let unMatchedIdOrEmail: AnyPublisher<Void, Never>
    let networkUnstable: AnyPublisher<Void, Never>
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
    
    let idAndEmail = input.userId
      .combineLatest(input.userEmail)
      .eraseToAnyPublisher()
    
    input.didTapNextButton
      .withLatestFrom(idAndEmail)
      .sinkOnMain(with: self) { owner, info in
        Task { await owner.requestTempoaryPassword(id: info.0, email: info.1) }
      }.store(in: &cancellables)
        
    let isValidIdFormat = input.endEditingUserId
      .withLatestFrom(input.userId)
      .map { $0.isValidateId }
    
    let isValidEmailFormat = input.endEditingUserEmail
      .withLatestFrom(input.userEmail)
      .map { $0.isValidateEmail() && $0.count <= 100 && !$0.isEmpty }
    
    let isEnabledConfirm = isValidIdFormat.combineLatest(isValidEmailFormat) { $0 && $1 }
        
    return Output(
      inValidIdFormat: isValidIdFormat.filter { !$0 }.map { _ in () }.eraseToAnyPublisher(),
      inValidEmailFormat: isValidEmailFormat.filter { !$0 }.map { _ in () }.eraseToAnyPublisher(),
      isEnabledNextButton: isEnabledConfirm.eraseToAnyPublisher(),
      unMatchedIdOrEmail: unMatchedIdOrEmailSubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension FindPasswordViewModel {
  func requestTempoaryPassword(id: String, email: String) async {
    do {
      try await useCase.sendTemporaryPassword(to: email, userName: id)
      await MainActor.run { coordinator?.attachResetPassword(userEmail: email, userName: id) }
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    if let error = error as? APIError, case .userNotFound = error {
      unMatchedIdOrEmailSubject.send(())
    } else {
      networkUnstableSubject.send(())
    }
  }
}
