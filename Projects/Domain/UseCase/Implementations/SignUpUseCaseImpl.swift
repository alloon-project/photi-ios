//
//  SignUpUseCaseImpl.swift
//  UseCase
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import Core
import Entity
import UseCase
import Repository

public class SignUpUseCaseImpl: SignUpUseCase {
  private let repository: SignUpRepository
  private var email: String?
  private var username: String?
  
  public init(repository: SignUpRepository) {
    self.repository = repository
  }
}

// MARK: - Public Methods
public extension SignUpUseCaseImpl {
  func configureEmail(_ email: String) {
    self.email = email
  }
  
  func configureUsername(_ username: String) {
    self.username = username
  }
}

// MARK: - API Methods
public extension SignUpUseCaseImpl {
  func requestVerificationCode(email: String) -> Single<Void> {
    return repository.requestVerificationCode(email: email)
  }
  
  func verifyCode(email: String, code: String) -> Single<Void> {
    return repository.verifyCode(
      email: email.trimmingCharacters(in: .whitespacesAndNewlines),
      code: code.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }
  
  func verifyUserName(_ username: String) -> Single<Void> {
    guard username.isValidateId else {
      return singleWithError(APIError.signUpFailed(reason: .invalidUserNameFormat))
    }
    
    return repository.verifyUseName(username)
  }
  
  func remainingRejoinDays(email: String) async throws -> Int {
    let withdrawalDate = try await repository.fetchWithdrawalDate(email: email).value
    
    let calendar = Calendar.current
    let now = calendar.startOfDay(for: Date())
    let start = calendar.startOfDay(for: withdrawalDate)
    let rawDays = calendar.dateComponents([.day], from: start, to: now).day ?? 0
    
    return 30 - rawDays
  }
  
  func register(password: String) -> Single<String> {
    guard let email, let username else {
      return singleWithError(APIError.serverError, type: String.self)
    }
    return repository.register(
      email: email,
      username: username,
      password: password.trimmingCharacters(in: .whitespacesAndNewlines)
    )
    .do { ServiceConfiguration.shared.setUserName($0) }
  }
}

// MARK: - Private Methods
private extension SignUpUseCaseImpl {
  func singleWithError<T>(_ error: Error, type: T.Type = Void.self) -> Single<T> {
    return Single<T>.create { single in
      single(.failure(error))
      return Disposables.create()
    }
  }
}
