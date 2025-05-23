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
  case organazieFailed(reason: OrganizedFailedReason)
  case tokenUnauthenticated
  /// 권한이 없는 요청입니다. 로그인 후에 다시 시도 해주세요.
  case tokenUnauthorized
  
  // MARK: - Profile Edit
  case userNotFound
  
  // MARK: - 비밀번호 변경
  
  /// 비밀번호와 비밀번호 재입력이 동일하지 않습니다.
  case passwordMatchInvalid
  /// 아이디 또는 비밀번호가 틀렸습니다.
  case loginUnauthenticated
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
    case invalidInvitationCode
    case alreadyUploadFeed
    case fileTooLarge
    case challengeLimitExceed
    case invalidFileFormat
  }
}

// MARK: - Organize
extension APIError {
  public enum OrganizedFailedReason {
    case emptyFileInvalid
    case fileSizeExceed
    case imageTypeUnsurported
  }
}
