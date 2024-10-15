//
//  APIError.swift
//  Entity
//
//  Created by jung on 5/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

public enum APIError: Error {
  public enum SignUpFailedReason {
    case emailAlreadyExists
    case invalidVerificationCode
    case emailNotFound
    case useNameAlreadyExists
    case invalidUseName
    case didNotVerifyEmail
    case passwordNotEqual
  }
  
  case authenticationFailed
  case clientError(code: String, message: String)
  case serverError
  case loginFailed
  case signUpFailed(reason: SignUpFailedReason)
  
  // MARK: - Profile Edit
  case tokenUnauthenticated
  case tokenUnauthorized
  case userNotFound
}
