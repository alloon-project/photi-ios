//
//  TempPasswordViewModel.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import Entity
import UseCase

protocol TempPasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func attachNewPassword()
}

protocol TempPasswordViewModelType {
  associatedtype Input
  associatedtype Output
  
  var coordinator: TempPasswordCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class TempPasswordViewModel: TempPasswordViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let useCase: LogInUseCase
  private let email: String
  private let name: String
  
  weak var coordinator: TempPasswordCoordinatable?
  
  private let invalidPasswordSubject = PassthroughSubject<Void, Never>()
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let isSuccessedResendSubject = PassthroughSubject<Bool, Never>()
  
  // MARK: - Input
  struct Input {
    let password: AnyPublisher<String, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapResendButton: AnyPublisher<Void, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let isEnabledNextButton: AnyPublisher<Bool, Never>
    let isSuccessedResend: AnyPublisher<Bool, Never>
    let invalidPassword: AnyPublisher<Void, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(
    useCase: LogInUseCase,
    email: String,
    name: String
  ) {
    self.useCase = useCase
    self.email = email
    self.name = name
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)
    
    input.didTapResendButton
      .sink(with: self) { owner, _ in
        Task { await owner.requestTempoaryPassword() }
      }.store(in: &cancellables)
    
    input.didTapNextButton
      .withLatestFrom(input.password)
      .sink(with: self) { owner, password in
        Task { await owner.validateTemporaryPassword(password) }
      }.store(in: &cancellables)
    
    let isEnabledNextButton = input.password.map { !$0.isEmpty }
    
    return Output(
      isEnabledNextButton: isEnabledNextButton.eraseToAnyPublisher(),
      isSuccessedResend: isSuccessedResendSubject.eraseToAnyPublisher(),
      invalidPassword: invalidPasswordSubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension TempPasswordViewModel {
  func requestTempoaryPassword() async {
    do {
      try await useCase.sendTemporaryPassword(to: email, userName: name)
      isSuccessedResendSubject.send(true)
    } catch {
      isSuccessedResendSubject.send(false)
    }
  }
  
  @MainActor func validateTemporaryPassword(_ password: String) async {
    let result = await useCase.verifyTemporaryPassword(password, name: name)

    switch result {
      case .success: coordinator?.attachNewPassword()
      case .mismatch: invalidPasswordSubject.send(())
      case .failure: networkUnstableSubject.send(())
    }
  }
}
