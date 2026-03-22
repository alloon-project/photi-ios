//
//  OAuthUseCaseImpl.swift
//  UseCase
//
//  Created by Claude on 3/15/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import Core
import UseCase
import Repository

public final class OAuthUseCaseImpl: OAuthUseCase {
  private let oauthRepository: OAuthRepository
  private let authRepository: AuthRepository

  public init(oauthRepository: OAuthRepository, authRepository: AuthRepository) {
    self.oauthRepository = oauthRepository
    self.authRepository = authRepository
  }
}

// MARK: - Public Methods
public extension OAuthUseCaseImpl {
  func login(provider: String, idToken: String) async throws -> OAuthLoginResult {
    let username = try await oauthRepository.login(provider: provider, idToken: idToken)

    if let username = username {
      ServiceConfiguration.shared.setUserName(username)
      return .existingUser(username: username)
    }

    return .newUser
  }

  func setUsername(_ username: String) async throws {
    try await oauthRepository.setUsername(username)
    ServiceConfiguration.shared.setUserName(username)
  }
}
