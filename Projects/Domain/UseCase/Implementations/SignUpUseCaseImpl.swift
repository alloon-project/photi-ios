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
    return asyncToSingle { [weak self] in
      guard let self = self else { throw CancellationError() }
      try await self.repository.requestVerificationCode(email: email)
    }
  }
  
  func verifyCode(email: String, code: String) -> Single<Void> {
    let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
    return asyncToSingle { [weak self] in
      guard let self = self else { throw CancellationError() }
      try await self.repository.verifyCode(email: trimmedEmail, code: trimmedCode)
    }
  }
  
  func verifyUserName(_ username: String) -> Single<Void> {
    guard username.isValidateId else {
      return singleWithError(APIError.signUpFailed(reason: .invalidUserNameFormat))
    }
    return asyncToSingle { [weak self] in
      guard let self = self else { throw CancellationError() }
      try await self.repository.verifyUseName(username)
    }
  }
  
  func remainingRejoinDays(email: String) async throws -> Int {
    let withdrawalDate = try await repository.fetchWithdrawalDate(email: email)
    
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
    let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
    return asyncToSingle { [weak self] in
      guard let self = self else { throw CancellationError() }
      let userName = try await self.repository.register(
        email: email,
        username: username,
        password: trimmed
      )
      ServiceConfiguration.shared.setUserName(userName)
      return userName
    }
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
  
  func asyncToSingle<T>(_ work: @escaping () async throws -> T) -> Single<T> {
    Single.create { single in
      let task = Task {
        do {
          let value = try await work()
          single(.success(value))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create { task.cancel() }
    }
  }
}
