//
//  EnterEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation
import Combine
import Entity
import UseCase

protocol EnterEmailCoordinatable: AnyObject {
  func attachVerifyEmail(userEmail: String)
  func didTapBackButton()
}

protocol EnterEmailViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EnterEmailCoordinatable? { get set }
}

final class EnterEmailViewModel: EnterEmailViewModelType {
  private var cancellables: Set<AnyCancellable> = []
  private let useCase: SignUpUseCase
  
  weak var coordinator: EnterEmailCoordinatable?
  
  private let duplicateEmailSubject = PassthroughSubject<Void, Never>()
  private let networkUnstableSubject = PassthroughSubject<Void, Never>()
  private let rejoinAvaildableDaySubject = PassthroughSubject<Int, Never>()
  
  private var lastRequestedEmail: String?
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
    let userEmail: AnyPublisher<String, Never>
    let endEditingUserEmail: AnyPublisher<Void, Never>
    let editingUserEmail: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let isValidEmailForm: AnyPublisher<Bool, Never>
    let isOverMaximumText: AnyPublisher<Bool, Never>
    let isEnabledNextButton: AnyPublisher<Bool, Never>
    let duplicateEmail: AnyPublisher<Void, Never>
    let rejoinAvaildableDay: AnyPublisher<Int, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: SignUpUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }.store(in: &cancellables)
    
    input.didTapNextButton
      .withLatestFrom(input.userEmail)
      .sinkOnMain(with: self) { owner, email in
        Task { await owner.requestVerificationCode(email: email) }
      }.store(in: &cancellables)
    
    let isValidEmailForm = input.endEditingUserEmail
      .withLatestFrom(input.userEmail)
      .filter { $0.count <= 100 && !$0.isEmpty }
      .map { $0.isValidateEmail() }
    
    let isOverMaximumText = input.editingUserEmail
      .withLatestFrom(input.userEmail)
      .map { $0.count > 100 }
    
    let isEnabledConfirm = input.userEmail
      .map { $0.isValidateEmail() && $0.count <= 100 }
    
    return Output(
      isValidEmailForm: isValidEmailForm.eraseToAnyPublisher(),
      isOverMaximumText: isOverMaximumText.eraseToAnyPublisher(),
      isEnabledNextButton: isEnabledConfirm.eraseToAnyPublisher(),
      duplicateEmail: duplicateEmailSubject.eraseToAnyPublisher(),
      rejoinAvaildableDay: rejoinAvaildableDaySubject.eraseToAnyPublisher(),
      networkUnstable: networkUnstableSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension EnterEmailViewModel {
  func requestVerificationCode(email: String) async {
    do {
      lastRequestedEmail = email
      try await useCase.requestVerificationCode(email: email)
      await MainActor.run {
        useCase.configureEmail(email)
        coordinator?.attachVerifyEmail(userEmail: email)
      }
    } catch {
      await MainActor.run { requestFailed(error: error) }
    }
  }
  
  func remainingRejoinDays(email: String) async {
    do {
      let days = try await useCase.remainingRejoinDays(email: email)
      rejoinAvaildableDaySubject.send(days)
    } catch {
      await MainActor.run { requestFailed(error: error) }
    }
  }
  
  func requestFailed(error: Error) {
    guard let error = error as? APIError else {
      return networkUnstableSubject.send(())
    }
    
    switch error {
      case let .signUpFailed(reason) where reason == .emailAlreadyExists:
        duplicateEmailSubject.send(())
      case let .signUpFailed(reason) where reason == .deletedUser:
        if let email = lastRequestedEmail {
          Task { await remainingRejoinDays(email: email) }
        }
      default:
        networkUnstableSubject.send(())
    }
  }
}
