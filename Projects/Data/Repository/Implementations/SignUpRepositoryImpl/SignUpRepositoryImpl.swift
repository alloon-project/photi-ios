//
//  SignUpRepositoryImpl.swift
//  DTO
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import DataMapper
import DTO
import Entity
import Repository
import PhotiNetwork

public struct SignUpRepositoryImpl: SignUpRepository {
  private let dataMapper: SignUpDataMapper
  
  public init(dataMapper: SignUpDataMapper) {
    self.dataMapper = dataMapper
  }
}

// MARK: - API Methods
public extension SignUpRepositoryImpl {
  func requestVerificationCode(email: String) async throws {
    let requestDTO = dataMapper.mapToRequestVerificationRequestDTO(email: email)
    try await requestAPI(
      SignUpAPI.requestVerificationCode(dto: requestDTO),
      responseType: SuccessResponseDTO.self
    )
  }
  
  func verifyCode(email: String, code: String) async throws {
    let requestDTO = dataMapper.mapToVerifyCodeRequestDTO(email: email, code: code)
    try await requestAPI(
      SignUpAPI.verifyCode(dto: requestDTO),
      responseType: SuccessResponseDTO.self
    )
  }
  
  func verifyUseName(_ userName: String) async throws {
    try await requestAPI(
      SignUpAPI.verifyUserName(userName),
      responseType: SuccessResponseDTO.self
    )
  }
  
  func register(
    email: String,
    username: String,
    password: String
  ) async throws -> String {
    let requestDTO = dataMapper.mapToRegisterRequestDTO(
      email: email,
      username: username,
      password: password
    )
    return try await requestAPI(
      SignUpAPI.register(dto: requestDTO),
      responseType: RegisterResponseDTO.self,
      behavior: .never
    ).username
  }
  
  func fetchWithdrawalDate(email: String) async throws -> Date {
    let response = try await requestAPI(
      SignUpAPI.deletedDate(email: email),
      responseType: DeletedDateResponseDTO.self
    )
    return response.deletedDate.toDate("YYYY-MM-dd") ?? Date()
  }
}
  
// MARK: - Private Methods
private extension SignUpRepositoryImpl {
  @discardableResult
  func requestAPI<T: Decodable>(
    _ api: SignUpAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    do {
      let provider = Provider<SignUpAPI>(stubBehavior: behavior)
      let result = try await provider.request(api, type: responseType.self)
      
      if (200..<300).contains(result.statusCode), let data = result.data {
        return data
      } else if result.statusCode == 400 {
        throw map400ToAPIError(result.code, result.message)
      } else if result.statusCode == 404 {
        throw APIError.signUpFailed(reason: .emailNotFound)
      } else if result.statusCode == 409 {
        throw map409ToAPIError(result.code, result.message)
      } else {
        throw APIError.serverError
      }
    } catch {
      throw error
    }
  }
  
  func map400ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "EMAIL_VALIDATION_INVALID" {
      return .signUpFailed(reason: .didNotVerifyEmail)
    } else if code == "USERNAME_FORMAT_INVALID" {
      return .signUpFailed(reason: .invalidUserNameFormat)
    } else if code == "EMAIL_VERIFICATION_CODE_INVALID" {
      return .signUpFailed(reason: .invalidVerificationCode)
    } else {
      return .clientError(code: code, message: message)
    }
  }

  func map409ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "EXISTING_EMAIL" {
      return .signUpFailed(reason: .emailAlreadyExists)
    } else if code == "UNAVAILABLE_USERNAME" {
      return .signUpFailed(reason: .invalidUserName)
    } else if code == "EXISTING_USERNAME" {
      return .signUpFailed(reason: .userNameAlreadyExists)
    } else if code == "DELETED_USER" {
      return .signUpFailed(reason: .deletedUser)
    } else {
      return .clientError(code: code, message: message)
    }
  }
}
