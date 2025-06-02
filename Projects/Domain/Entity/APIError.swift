//
//  APIError.swift
//  Entity
//
//  Created by jung on 5/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

public enum APIError: Error {
  case authenticationFailed
  case clientError(code: String, message: String)
  case serverError
  case loginFailed(reason: LogInFailedReason)
  case signUpFailed(reason: SignUpFailedReason)
  case challengeFailed(reason: ChallengeFailedReason)
  case myPageFailed(reason: MyPageFailedReason)
  case organazieFailed(reason: OrganizedFailedReason)

  // MARK: - Profile Edit
  case userNotFound
}

extension APIError {
  public enum LogInFailedReason {
    case invalidEmailOrPassword
    case deletedUser
  }
}

// MARK: - SignUp
extension APIError {
  public enum SignUpFailedReason {
    case emailAlreadyExists
    case userNameAlreadyExists
    case invalidUserName
    case invalidUserNameFormat
    case invalidVerificationCode
    case didNotVerifyEmail
    case emailNotFound
    case passwordNotEqual
  }
}

// MARK: - Challenge
extension APIError {
  public enum ChallengeFailedReason {
    case feedNotFound
    case feedCommentNotFound
    case challengeNotFound
    case userNotFound
    case notChallengeMemeber
    case alreadyJoinedChallenge
    case alreadyUploadFeed
    case fileTooLarge
    case challengeLimitExceed
    case invalidFileFormat
  }
}

// MARK: - MyPage
extension APIError {
  public enum MyPageFailedReason {
    case userNotFound
    case passwordMatchInvalid
  }
}

// MARK: - Organize
extension APIError {
  public enum OrganizedFailedReason {
    case emptyFileInvalid
    case fileSizeExceed
    case imageTypeUnsurported
    case payloadIsNil
  }
}
