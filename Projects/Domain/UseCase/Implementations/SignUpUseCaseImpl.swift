//
//  SignUpUseCaseImpl.swift
//  UseCase
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
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
  func requestVerificationCode(email: String) async throws {
    do {
      try await repository.requestVerificationCode(email: email)
    } catch {
      throw CancellationError()
    }
  }
  
  func verifyCode(email: String, code: String) async throws {
    let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
    do {
      try await repository.verifyCode(email: trimmedEmail, code: trimmedCode)
    } catch {
      throw CancellationError()
    }
  }
  
  func verifyUserName(_ username: String) async throws {
    guard username.isValidateId else {
      throw APIError.signUpFailed(reason: .invalidUserNameFormat)
    }
    do {
      try await repository.verifyUseName(username)
    } catch {
      throw CancellationError()
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
  
  func register(password: String) async throws -> String {
    guard let email, let username else {
      throw APIError.serverError
    }
    let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
    do {
      let userName = try await repository.register(
        email: email,
        username: username,
        password: trimmed
      )
      ServiceConfiguration.shared.setUserName(userName)
      return userName
    } catch {
      throw CancellationError()
    }
  }
}
