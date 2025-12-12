//
//  VerifyEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import Entity
import UseCase

protocol VerifyEmailCoordinatable: AnyObject {
  func didTapBackButton()
  func didTapNextButton(verificationCode: String)
}

protocol VerifyEmailViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: VerifyEmailCoordinatable? { get set }
}

final class VerifyEmailViewModel: VerifyEmailViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let useCase: SignUpUseCase
  private let email: String
  
  weak var coordinator: VerifyEmailCoordinatable?
  
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let invalidVerificationCodeSubject = PassthroughSubject<Void, Never>()
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapResendButton: AnyPublisher<Void, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
    let verificationCode: AnyPublisher<String, Never>
  }
  
  // MARK: - Output
  struct Output {
    let isEnabledNextButton: AnyPublisher<Bool, Never>
    let networkUnstable: AnyPublisher<Void, Never>
    let invalidVerificationCode: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: SignUpUseCase, email: String) {
    self.useCase = useCase
    self.email = email
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)
    
    input.didTapNextButton
      .withLatestFrom(input.verificationCode)
      .filter { $0.count == 4 }
      .sink(with: self) { owner, code in
        Task { await owner.verifyCode(email: owner.email, code: code) }
      }.store(in: &cancellables)
    
    input.didTapResendButton
      .sink(with: self) { owner, _ in
        Task { await owner.requestVerificationCode(email: owner.email) }
      }.store(in: &cancellables)
    
    let isEnabledNextButton = input.verificationCode
      .map { $0.count == 4 }
    
    return Output(
      isEnabledNextButton: isEnabledNextButton.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher(),
      invalidVerificationCode: invalidVerificationCodeSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension VerifyEmailViewModel {
  func requestVerificationCode(email: String) async {
    do {
      try await useCase.requestVerificationCode(email: email)
    } catch {
      networkUnstableSubject.send(())
    }
  }
  
  func verifyCode(email: String, code: String) async {
    do {
      try await useCase.verifyCode(email: email, code: code)
      coordinator?.didTapNextButton(verificationCode: code)
    } catch {
      requestFailed(error: error)
    }
  }
  
  func requestFailed(error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableSubject.send(())
    }
    switch error {
      case let .signUpFailed(reason) where reason == .invalidVerificationCode:
        return invalidVerificationCodeSubject.send(())
      default:
        return networkUnstableSubject.send(())
    }
  }
}
