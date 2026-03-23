//
//  OAuthRepository.swift
//  Domain
//
//  Created by Claude on 3/15/26.
//  Copyright © 2026 com.photi. All rights reserved.
//

public protocol OAuthRepository {
  /// OAuth 로그인
  func login(provider: String, idToken: String) async throws -> String?

  /// OAuth 신규 사용자 username 설정
  func setUsername(_ username: String) async throws
}
