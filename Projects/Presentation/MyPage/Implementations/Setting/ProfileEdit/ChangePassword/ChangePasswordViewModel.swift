//
//  ChangePasswordViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 8/16/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Combine
import CoreUI
import Entity
import UseCase

protocol ChangePasswordCoordinatable: AnyObject {
  func didTapBackButton()
  func didChangedPassword()
  func attachResetPassword(email: String, name: String)
  func authenticationFailed()
}

protocol ChangePasswordViewModelType {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ChangePasswordCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class ChangePasswordViewModel: ChangePasswordViewModelType {
  private let useCase: ProfileEditUseCase
  private var cancellables = Set<AnyCancellable>()
  
  private let name: String
  private let email: String
  
  weak var coordinator: ChangePasswordCoordinatable?
  
  private let invalidCurrentPasswordRelay = PassthroughSubject<Void, Never>()
  private let duplicatePasswordRelay = PassthroughSubject<Void, Never>()
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let currentPassword: AnyPublisher<String, Never>
    let newPassword: AnyPublisher<String, Never>
    let reEnteredPassword: AnyPublisher<String, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapForgetPasswordButton: AnyPublisher<Void, Never>
    let didTapChangePasswordButton: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let containAlphabet: AnyPublisher<Bool, Never>
    let containNumber: AnyPublisher<Bool, Never>
    let containSpecial: AnyPublisher<Bool, Never>
    let isValidRange: AnyPublisher<Bool, Never>
    let isValidNewPassword: AnyPublisher<Bool, Never>
    let correspondNewPassword: AnyPublisher<Bool, Never>
    let isEnabledNextButton: AnyPublisher<Bool, Never>
    let invalidCurrentPassword: AnyPublisher<Void, Never>
    let duplicatePassword: AnyPublisher<Void, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(email: String, name: String, useCase: ProfileEditUseCase) {
    self.email = email
    self.name = name
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    bind(input: input)
    
    let containAlphabet = input.newPassword
      .map { $0.contain("[a-zA-Z]") }
    
    let containNumber = input.newPassword
      .map { $0.contain("[0-9]") }
    
    let containSpecial = input.newPassword
      .map { $0.contain("[^a-zA-Z0-9]") }
    
    let isValidRange = input.newPassword
      .map { $0.count >= 8 && $0.count <= 30 }
    
    let isValidNewPassword = containAlphabet
      .combineLatest(containNumber, containSpecial)
      .combineLatest(isValidRange)
      .map { checks, isValidRange in
        checks.0 && checks.1 && checks.2 && isValidRange
      }
      .eraseToAnyPublisher()
    
    let correspondNewPassword = input.newPassword
      .combineLatest(input.reEnteredPassword)
      .map { password, reEnteredPassword in
        password == reEnteredPassword
      }
      .eraseToAnyPublisher()

    let isEnabledNextButton = isValidNewPassword
      .combineLatest(correspondNewPassword, input.currentPassword.map { $0.isValidPassword })
      .map { isValidNewPassword, correspondNewPassword, isValidCurrentPassword in
        isValidNewPassword && correspondNewPassword && isValidCurrentPassword
      }
      .eraseToAnyPublisher()
        
    return Output(
      containAlphabet: containAlphabet.eraseToAnyPublisher(),
      containNumber: containNumber.eraseToAnyPublisher(),
      containSpecial: containSpecial.eraseToAnyPublisher(),
      isValidRange: isValidRange.eraseToAnyPublisher(),
      isValidNewPassword: isValidNewPassword.eraseToAnyPublisher(),
      correspondNewPassword: correspondNewPassword.eraseToAnyPublisher(),
      isEnabledNextButton: isEnabledNextButton.eraseToAnyPublisher(),
      invalidCurrentPassword: invalidCurrentPasswordRelay.eraseToAnyPublisher(),
      duplicatePassword: duplicatePasswordRelay.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
  
  func bind(input: Input) {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)
    
    input.didTapForgetPasswordButton
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.requestTempoaryPassword() }
      }
      .store(in: &cancellables)
    
    let passwords = input.currentPassword.combineLatest(input.newPassword)
    
    input.didTapChangePasswordButton
      .withLatestFrom(passwords)
      .sinkOnMain(with: self) { owner, info in
        Task { await owner.changePassword(from: info.0, to: info.1) }
      }
      .store(in: &cancellables)
  }
}

// MARK: - Private Methods
private extension ChangePasswordViewModel {
  @MainActor func changePassword(from password: String, to newPassword: String) async {
    guard password != newPassword else { return duplicatePasswordRelay.send(()) }
      
    do {
      try await useCase.changePassword(from: password, to: newPassword)
      coordinator?.didChangedPassword()
    } catch {
      requestFailed(with: error)
    }
  }
  
  @MainActor func requestTempoaryPassword() async {
    do {
      try await useCase.sendTemporaryPassword(to: email, userName: name)
      coordinator?.attachResetPassword(email: email, name: name)
    } catch {
      networkUnstableRelay.send(())
    }
  }
  
  @MainActor func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.send(()) }
    
    switch error {
      case let .myPageFailed(reason) where reason == .loginUnAuthenticated:
        invalidCurrentPasswordRelay.send(())
      case .authenticationFailed:
        coordinator?.authenticationFailed()
      default: networkUnstableRelay.send(())
    }
  }
}
