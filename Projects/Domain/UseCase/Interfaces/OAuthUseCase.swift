//
//  OAuthUseCase.swift
//  UseCase
//
//  Created by Claude on 3/15/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

public enum OAuthLoginResult {
  case existingUser(username: String)
  case newUser
}

public protocol OAuthUseCase {
  func login(provider: String, idToken: String) async throws -> OAuthLoginResult
  func setUsername(_ username: String) async throws
}
