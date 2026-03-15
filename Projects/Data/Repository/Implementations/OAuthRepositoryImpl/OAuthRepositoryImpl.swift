//
//  OAuthRepositoryImpl.swift
//  Data
//
//  Created by Claude on 3/15/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import Core
import DTO
import Repository
import PhotiNetwork

public struct OAuthRepositoryImpl: OAuthRepository {
  public init() { }
}

// MARK: - Public Methods
public extension OAuthRepositoryImpl {
  func login(provider: String, idToken: String) async throws -> String? {
    return try await requestUnAuthorizableAPI(
      api: OAuthAPI.login(provider: provider, idToken: idToken),
      responseType: OAuthLoginResponseDTO.self
    ).username
  }

  func setUsername(_ username: String) async throws {
    let requestDTO = OAuthUsernameRequestDTO(username: username)

    try await requestAuthorizableAPI(
      api: OAuthAPI.setUsername(dto: requestDTO),
      responseType: SuccessResponseDTO.self
    )
  }
}

// MARK: - Private Methods
private extension OAuthRepositoryImpl {
  @discardableResult
  func requestAuthorizableAPI<T: Decodable>(
    api: OAuthAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    do {
      let provider = Provider<OAuthAPI>(
        stubBehavior: behavior,
        session: .init(interceptor: AuthenticationInterceptor())
      )

      let result = try await provider.request(api, type: responseType.self)
      if (200..<300).contains(result.statusCode), let data = result.data {
        return data
      } else if result.statusCode == 401 {
        throw APIError.authenticationFailed
      } else if result.statusCode == 403 {
        throw APIError.authenticationFailed
      } else if result.statusCode == 409 {
        throw APIError.oauthFailed(reason: .usernameAlreadyExists)
      } else {
        throw APIError.serverError
      }
    } catch {
      if case NetworkError.networkFailed(reason: .interceptorMapping) = error {
        throw APIError.authenticationFailed
      } else {
        throw error
      }
    }
  }

  @discardableResult
  func requestUnAuthorizableAPI<T: Decodable>(
    api: OAuthAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    let provider = Provider<OAuthAPI>(stubBehavior: behavior)
    let result = try await provider.request(api, type: responseType.self)

    if (200..<300).contains(result.statusCode), let data = result.data {
      return data
    } else if result.statusCode == 401 {
      throw APIError.oauthFailed(reason: .invalidIdToken)
    } else if result.statusCode == 404 {
      throw APIError.userNotFound
    } else {
      throw APIError.serverError
    }
  }
}
