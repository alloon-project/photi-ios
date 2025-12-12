//
//  NewPasswordViewModel.swift
//  LogInImpl
//
//  Created by wooseob on 6/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import UseCase

protocol NewPasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func didFinishUpdatePassword()
}

final class NewPasswordViewModel {
  weak var coordinator: NewPasswordCoordinatable?

  private var cancellables = Set<AnyCancellable>()
  private let useCase: LogInUseCase
  
  private let isSuccessedUpdatePasswordSubject = PassthroughSubject<Bool, Never>()
  private let isStartedUpdatePasswordSubject = PassthroughSubject<Bool, Never>()

  // MARK: - Input
  struct Input {
    let password: AnyPublisher<String, Never>
    let reEnteredPassword: AnyPublisher<String, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapContinueButton: AnyPublisher<Void, Never>
    let didTapConfirmButtonAtAlert: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let containAlphabet: AnyPublisher<Bool, Never>
    let containNumber: AnyPublisher<Bool, Never>
    let containSpecial: AnyPublisher<Bool, Never>
    let isValidRange: AnyPublisher<Bool, Never>
    let isValidPassword: AnyPublisher<Bool, Never>
    let correspondPassword: AnyPublisher<Bool, Never>
    let isEnabledNextButton: AnyPublisher<Bool, Never>
    let isSuccessedUpdatePassword: AnyPublisher<Bool, Never>
    let isStartedUpdatePassword: AnyPublisher<Bool, Never>
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
    
    input.didTapContinueButton
      .withLatestFrom(input.password)
      .sink(with: self) { owner, password in
        Task { await owner.updatePassword(password) }
      }.store(in: &cancellables)
    
    input.didTapConfirmButtonAtAlert
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didFinishUpdatePassword()
      }.store(in: &cancellables)
    
    let containAlphabet = input.password
      .map { $0.contain("[a-zA-Z]") }
    
    let containNumber = input.password
      .map { $0.contain("[0-9]") }
    
    let containSpecial = input.password
      .map { $0.contain("[^a-zA-Z0-9]") }
    
    let isValidRange = input.password
      .map { $0.count >= 8 && $0.count <= 30 }
    
    let isValidPassword = Publishers.CombineLatest4(
      containAlphabet, containNumber, containSpecial, isValidRange
    ).map { $0 && $1 && $2 && $3 }
    
    let correspondPassword = input.password
      .combineLatest(input.reEnteredPassword) { $0 == $1 }
    
    let isEnabledNextButton = isValidPassword
      .combineLatest(correspondPassword) { $0 && $1 }

    return Output(
      containAlphabet: containAlphabet.eraseToAnyPublisher(),
      containNumber: containNumber.eraseToAnyPublisher(),
      containSpecial: containSpecial.eraseToAnyPublisher(),
      isValidRange: isValidRange.eraseToAnyPublisher(),
      isValidPassword: isValidPassword.eraseToAnyPublisher(),
      correspondPassword: correspondPassword,
      isEnabledNextButton: isEnabledNextButton,
      isSuccessedUpdatePassword: isSuccessedUpdatePasswordSubject.eraseToAnyPublisher(),
      isStartedUpdatePassword: isStartedUpdatePasswordSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension NewPasswordViewModel {
  func updatePassword(_ newPassword: String) async {
    do {
      isStartedUpdatePasswordSubject.send(true)
      try await useCase.updatePassword(newPassword)
      isStartedUpdatePasswordSubject.send(false)
      isSuccessedUpdatePasswordSubject.send(true)
    } catch {
      isSuccessedUpdatePasswordSubject.send(false)
      isStartedUpdatePasswordSubject.send(false)
    }
  }
}
