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
    
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(SignUpAPI.requestVerificationCode(dto: requestDTO)).value
          
          if result.statusCode == 201 {
            single(.success(()))
          } else if result.statusCode == 409 {
            single(.failure(APIError.signUpFailed(reason: .emailAlreadyExists)))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(APIError.serverError))
        }
      }
      
      return Disposables.create()
    }
  }
  
  public func verifyCode(email: String, code: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToVerifyCodeRequestDTO(email: email, code: code)
    
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(SignUpAPI.verifyCode(dto: requestDTO)).value
          
          if result.statusCode == 200 {
            single(.success(()))
          } else if result.statusCode == 400 {
            single(.failure(APIError.signUpFailed(reason: .invalidVerificationCode)))
          } else if result.statusCode == 404 {
            single(.failure(APIError.signUpFailed(reason: .emailNotFound)))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(APIError.serverError))
        }
      }
      
      return Disposables.create()
    }
  }
  
  public func verifyUseName(_ userName: String) -> Single<Void> {
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(SignUpAPI.verifyUserName(userName)).value
          
          if result.statusCode == 200 {
            single(.success(()))
          } else if result.statusCode == 409 {
            single(.failure(APIError.signUpFailed(reason: .useNameAlreadyExists)))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(APIError.serverError))
        }
      }
      return Disposables.create()
    }
  }
  
  public func register(
    email: String,
    verificaionCode: String,
    username: String,
    password: String,
    passwordReEnter: String
  ) -> Single<String> {
    let requestDTO = dataMapper.mapToRegisterRequestDTO(
      email: email,
      verificationCode: verificaionCode,
      username: username,
      password: password,
      passwordReEnter: passwordReEnter
    )
    
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(
              SignUpAPI.register(dto: requestDTO),
              type: RegisterResponseDTO.self
            ).value
          
          if result.statusCode == 400 {
            single(.failure(register400Error(result.code)))
          } else if result.statusCode == 409 {
            single(.failure(register409Error(result.code)))
          } else if result.statusCode == 201, let userName = result.data?.userName {
            single(.success(userName))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(APIError.serverError))
        }
      }
      return Disposables.create()
    }
  }
}

// MARK: - Private Methods
private extension SignUpRepositoryImpl {
  func register400Error(_ code: String) -> APIError {
    if code == "EMAIL_VALIDATION_INVALID" {
      return .signUpFailed(reason: .didNotVerifyEmail)
    } else if code == "PASSWORD_MATCH_INVALID" {
      return .signUpFailed(reason: .passwordNotEqual)
    } else {
      return .serverError
    }
  }
  
  func register409Error(_ code: String) -> APIError {
    if code == "EXISTING_USER" {
      return .signUpFailed(reason: .emailAlreadyExists)
    } else if code == "UNAVAILABLE_USERNAME" {
      return .signUpFailed(reason: .invalidUseName)
    } else if code == "EXISTING_USERNAME" {
      return .signUpFailed(reason: .useNameAlreadyExists)
    } else {
      return .serverError
    }
  }
}
