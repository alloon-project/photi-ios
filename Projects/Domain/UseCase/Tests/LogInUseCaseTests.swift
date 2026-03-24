//
//  LogInUseCaseTests.swift
//  UseCaseImplTests
//

import XCTest
import Entity
@testable import UseCaseImpl

final class LogInUseCaseTests: XCTestCase {
  private var sut: LogInUseCaseImpl!
  private var mockLoginRepo: MockLogInRepository!
  private var mockAuthRepo: MockAuthRepository!

  override func setUp() {
    super.setUp()
    mockLoginRepo = MockLogInRepository()
    mockAuthRepo = MockAuthRepository()
    sut = LogInUseCaseImpl(authRepository: mockAuthRepo, loginrepository: mockLoginRepo)
  }

  override func tearDown() {
    sut = nil
    mockLoginRepo = nil
    mockAuthRepo = nil
    super.tearDown()
  }
}

// MARK: - login(username:password:)
extension LogInUseCaseTests {
  func test_login_성공시_에러없이_완료() async {
    mockLoginRepo.logInResult = .success("testUser")

    await XCTAssertNoThrowAsync {
      try await self.sut.login(username: "testUser", password: "password123")
    }
  }

  func test_login_잘못된_비밀번호시_에러던짐() async {
    mockLoginRepo.logInResult = .failure(APIError.loginFailed(reason: .invalidEmailOrPassword))

    await XCTAssertThrowsErrorAsync(try await sut.login(username: "testUser", password: "wrongPw")) { error in
      guard case APIError.loginFailed(let reason) = error else {
        return XCTFail("예상치 못한 에러 타입: \(error)")
      }
      XCTAssertEqual(reason, .invalidEmailOrPassword)
    }
  }

  func test_login_탈퇴한_유저시_에러던짐() async {
    mockLoginRepo.logInResult = .failure(APIError.loginFailed(reason: .deletedUser))

    await XCTAssertThrowsErrorAsync(try await sut.login(username: "deletedUser", password: "pw")) { error in
      guard case APIError.loginFailed(let reason) = error else {
        return XCTFail("예상치 못한 에러 타입: \(error)")
      }
      XCTAssertEqual(reason, .deletedUser)
    }
  }
}

// MARK: - verifyTemporaryPassword(_:name:)
extension LogInUseCaseTests {
  func test_verifyTemporaryPassword_성공시_토큰저장하고_success반환() async {
    mockLoginRepo.logInResult = .success("testUser")
    mockAuthRepo.storedToken = "temp-access-token"

    let result = await sut.verifyTemporaryPassword("tempPw123", name: "testUser")

    XCTAssertEqual(result, .success)
    // 임시 토큰은 authRepo에서 제거되어야 함
    XCTAssertNil(mockAuthRepo.storedToken)
  }

  func test_verifyTemporaryPassword_토큰없으면_mismatch반환() async {
    mockLoginRepo.logInResult = .success("testUser")
    mockAuthRepo.storedToken = nil  // 토큰 없는 상태

    let result = await sut.verifyTemporaryPassword("tempPw123", name: "testUser")

    XCTAssertEqual(result, .mismatch)
  }

  func test_verifyTemporaryPassword_잘못된비밀번호시_mismatch반환() async {
    mockLoginRepo.logInResult = .failure(APIError.loginFailed(reason: .invalidEmailOrPassword))

    let result = await sut.verifyTemporaryPassword("wrongPw", name: "testUser")

    XCTAssertEqual(result, .mismatch)
  }

  func test_verifyTemporaryPassword_탈퇴유저시_mismatch반환() async {
    mockLoginRepo.logInResult = .failure(APIError.loginFailed(reason: .deletedUser))

    let result = await sut.verifyTemporaryPassword("anyPw", name: "deletedUser")

    XCTAssertEqual(result, .mismatch)
  }

  func test_verifyTemporaryPassword_네트워크에러시_failure반환() async {
    mockLoginRepo.logInResult = .failure(APIError.serverError)

    let result = await sut.verifyTemporaryPassword("anyPw", name: "testUser")

    XCTAssertEqual(result, .failure)
  }
}

// MARK: - updatePassword(_:)
extension LogInUseCaseTests {
  func test_updatePassword_임시토큰없으면_authenticationFailed던짐() async {
    // verifyTemporaryPassword 호출 없이 바로 updatePassword 호출
    await XCTAssertThrowsErrorAsync(try await sut.updatePassword("newPassword123")) { error in
      XCTAssertEqual(error as? APIError, .authenticationFailed)
    }
  }

  func test_updatePassword_성공시_토큰정리됨() async {
    // 먼저 verifyTemporaryPassword로 임시 토큰 세팅
    mockLoginRepo.logInResult = .success("testUser")
    mockAuthRepo.storedToken = "temp-access-token"
    _ = await sut.verifyTemporaryPassword("tempPw", name: "testUser")

    mockLoginRepo.updatePasswordError = nil

    await XCTAssertNoThrowAsync {
      try await self.sut.updatePassword("newPassword123")
    }
    // 완료 후 authRepo 토큰 없어야 함
    XCTAssertNil(mockAuthRepo.storedToken)
  }

  func test_updatePassword_실패시_토큰정리됨() async {
    // verifyTemporaryPassword로 임시 토큰 세팅
    mockLoginRepo.logInResult = .success("testUser")
    mockAuthRepo.storedToken = "temp-access-token"
    _ = await sut.verifyTemporaryPassword("tempPw", name: "testUser")

    mockLoginRepo.updatePasswordError = APIError.serverError

    await XCTAssertThrowsErrorAsync(try await sut.updatePassword("newPassword123")) { _ in }
    // 실패해도 토큰은 정리되어야 함
    XCTAssertNil(mockAuthRepo.storedToken)
  }
}

// MARK: - XCTest Async Helpers
private func XCTAssertNoThrowAsync(
  _ expression: @escaping () async throws -> Void,
  file: StaticString = #filePath,
  line: UInt = #line
) async {
  do {
    try await expression()
  } catch {
    XCTFail("예상치 못한 에러 발생: \(error)", file: file, line: line)
  }
}

private func XCTAssertThrowsErrorAsync<T>(
  _ expression: @autoclosure @escaping () async throws -> T,
  file: StaticString = #filePath,
  line: UInt = #line,
  _ errorHandler: (Error) -> Void = { _ in }
) async {
  do {
    _ = try await expression()
    XCTFail("에러가 발생해야 하는데 발생하지 않음", file: file, line: line)
  } catch {
    errorHandler(error)
  }
}
