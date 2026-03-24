//
//  MockLogInRepository.swift
//  UseCaseImplTests
//

import Entity
import Repository

final class MockLogInRepository: LogInRepository {
  // MARK: - logIn
  var logInResult: Result<String, Error> = .success("testUser")
  var logInCallCount = 0

  func logIn(userName: String, password: String) async throws -> String {
    logInCallCount += 1
    return try logInResult.get()
  }

  // MARK: - requestUserInformation
  var requestUserInformationError: Error?
  func requestUserInformation(email: String) async throws {
    if let error = requestUserInformationError { throw error }
  }

  // MARK: - requestTemporaryPassword
  var requestTemporaryPasswordError: Error?
  func requestTemporaryPassword(email: String, userName: String) async throws {
    if let error = requestTemporaryPasswordError { throw error }
  }

  // MARK: - updatePassword
  var updatePasswordError: Error?
  func updatePassword(from password: String, newPassword: String) async throws {
    if let error = updatePasswordError { throw error }
  }
}
