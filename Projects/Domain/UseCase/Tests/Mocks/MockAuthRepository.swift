//
//  MockAuthRepository.swift
//  UseCaseImplTests
//

import Repository

final class MockAuthRepository: AuthRepository {
  var storedToken: String?
  var isLogInResult: Bool = false

  func isLogIn() async throws -> Bool {
    return isLogInResult
  }

  func accessToken() -> String? {
    return storedToken
  }

  func storeAccessToken(_ token: String) {
    storedToken = token
  }

  func removeToken() {
    storedToken = nil
  }
}
