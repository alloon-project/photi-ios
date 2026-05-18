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

  /// 카카오 회원 탈퇴 - SDK unlink + 서버 API 호출
  func withdrawKakao() async throws

  /// 구글 회원 탈퇴 - SDK disconnect + 서버 API 호출
  func withdrawGoogle() async throws

  /// 애플 회원 탈퇴 - 서버에서 revoke 처리
  func withdrawApple() async throws
}
