//
//  OAuthRepositoryImpl.swift
//  Data
//
//  Created by Claude on 3/15/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

import Core
import DTO
import Entity
import Repository
import PhotiNetwork
import KakaoSDKUser

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

  func withdrawKakao() async throws {
    let sub = try await fetchKakaoUserId()
    try await unlinkKakao()
    try await requestWithdraw(provider: "KAKAO", sub: sub)
  }

  func withdrawGoogle() async throws {
    // TODO: 구글 SDK 연동 후 구현
    // 1. GIDSignIn.sharedInstance.currentUser?.userID로 sub 획득
    // 2. GIDSignIn.sharedInstance.disconnect()로 연결 해제
    // 3. requestWithdraw(provider: "GOOGLE", sub: sub) 호출
    throw APIError.serverError
  }

  func withdrawApple() async throws {
    // TODO: 애플 재인증 후 authorization code 획득하여 서버 전달
    // ASAuthorizationAppleIDProvider를 사용하여 재인증
    throw APIError.serverError
  }
}

// MARK: - Kakao SDK Methods
private extension OAuthRepositoryImpl {
  func fetchKakaoUserId() async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.me { user, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let userId = user?.id else {
          continuation.resume(throwing: APIError.serverError)
          return
        }

        continuation.resume(returning: String(userId))
      }
    }
  }

  func unlinkKakao() async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      UserApi.shared.unlink { error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }
        continuation.resume()
      }
    }
  }
}

// MARK: - Server API Methods
private extension OAuthRepositoryImpl {
  func requestWithdraw(provider: String, sub: String) async throws {
    let requestDTO = OAuthWithdrawRequestDTO(provider: provider, sub: sub)

    try await requestAuthorizableAPI(
      api: OAuthAPI.withdrawKakaoGoogle(dto: requestDTO),
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
