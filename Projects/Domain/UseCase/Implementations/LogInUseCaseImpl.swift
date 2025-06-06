//
//  LogInUseCaseImpl.swift
//  UseCase
//
//  Created by jung on 8/13/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Core
import Entity
import UseCase
import Repository

public final class LogInUseCaseImpl: LogInUseCase {
  private var temporaryToken: String?
  private var temporaryPassword: String?
  private let authRepository: AuthRepository
  private let loginrepository: LogInRepository
  
  public init(authRepository: AuthRepository, loginrepository: LogInRepository) {
    self.authRepository = authRepository
    self.loginrepository = loginrepository
  }
}

// MARK: - Public Methods
public extension LogInUseCaseImpl {
  func login(username: String, password: String) -> Single<Void> {
    loginrepository.logIn(userName: username, password: password)
      .do { ServiceConfiguration.shared.setUseName($0) }
      .map { _ in () }
  }
  
  func sendUserInformation(to email: String) -> Single<Void> {
    loginrepository.requestUserInformation(email: email)
  }
  
  func sendTemporaryPassword(to email: String, userName: String) -> Single<Void> {
    loginrepository.requestTemporaryPassword(email: email, userName: userName)
  }
  
  func verifyTemporaryPassword(_ password: String, name: String) async -> VerifyTemporaryPasswordResult {
    do {
      try await loginrepository.logIn(userName: name, password: password).value
      
      guard let token = authRepository.accessToken() else { return .mismatch }
      authRepository.removeToken()
      self.temporaryToken = token
      self.temporaryPassword = password
      
      return .success
    } catch {
      return handledVerifyTemporaryPasswordError(with: error)
    }
  }
  
  func updatePassword(_ newPassword: String) async throws {
    guard let temporaryToken, let temporaryPassword else { throw APIError.authenticationFailed }

    do {
      authRepository.storeAccessToken(temporaryToken)
      try await loginrepository.updatePassword(from: temporaryPassword, newPassword: newPassword).value
      authRepository.removeToken()
      self.temporaryToken = nil
      self.temporaryPassword = nil
    } catch {
      authRepository.removeToken()
      throw error
    }
  }
}

// MARK: - Private Methods
private extension LogInUseCaseImpl {
  func handledVerifyTemporaryPasswordError(with error: Error) -> VerifyTemporaryPasswordResult {
    guard let error = error as? APIError else { return .failure }
    
    switch error {
      case let .loginFailed(reason) where reason == .invalidEmailOrPassword:
        return .mismatch
      case let .loginFailed(reason) where reason == .deletedUser:
        return .mismatch
      default: return .failure
    }
  }
}
