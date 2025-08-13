//
//  SignUpRepositoryImpl.swift
//  DTO
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
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
  
  public func requestVerificationCode(email: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToRequestVerificationRequestDTO(email: email)
    return requestAPI(
      SignUpAPI.requestVerificationCode(dto: requestDTO),
      responseType: SuccessResponseDTO.self,
      behavior: .never
    )
    .map { _ in () }
  }
  
  public func verifyCode(email: String, code: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToVerifyCodeRequestDTO(email: email, code: code)
    return requestAPI(
      SignUpAPI.verifyCode(dto: requestDTO),
      responseType: SuccessResponseDTO.self,
      behavior: .never
    )
    .map { _ in () }
  }
  
  public func verifyUseName(_ userName: String) -> Single<Void> {
    return requestAPI(
      SignUpAPI.verifyUserName(userName),
      responseType: SuccessResponseDTO.self,
      behavior: .never
    )
    .map { _ in () }
  }
  
  public func register(
    email: String,
    username: String,
    password: String
  ) -> Single<String> {
    let requestDTO = dataMapper.mapToRegisterRequestDTO(
      email: email,
      username: username,
      password: password
    )
    return requestAPI(
      SignUpAPI.register(dto: requestDTO),
      responseType: RegisterResponseDTO.self,
      behavior: .never
    )
    .map { $0.username }
  }
}

// MARK: - Private Methods
private extension SignUpRepositoryImpl {
  func requestAPI<T: Decodable>(
    _ api: SignUpAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<SignUpAPI>(stubBehavior: behavior)
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(map400ToAPIError(result.code, result.message)))
          } else if result.statusCode == 404 {
            single(.failure(APIError.signUpFailed(reason: .emailNotFound)))
          } else if result.statusCode == 409 {
            single(.failure(map409ToAPIError(result.code, result.message)))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(error))
        }
      }
      
      return Disposables.create()
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
