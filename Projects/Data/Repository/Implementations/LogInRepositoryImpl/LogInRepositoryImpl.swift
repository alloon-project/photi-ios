//
//  LogInRepositoryImpl.swift
//  DTO
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core
import DataMapper
import DTO
import Entity
import Repository
import PhotiNetwork

public struct LogInRepositoryImpl: LogInRepository {
  private let dataMapper: LogInDataMapper
  
  public init(dataMapper: LogInDataMapper) {
    self.dataMapper = dataMapper
  }
}

// MARK: - Public Methods
public extension LogInRepositoryImpl {
  func logIn(userName: String, password: String) async throws -> String {
    let requestDTO = dataMapper.mapToLogInRequestDTO(userName: userName, password: password)
    
    return try await requestUnAuthorizableAPI(
      api: LogInAPI.login(dto: requestDTO),
      responseType: LogInResponseDTO.self
    ).username
  }
  
  func requestUserInformation(email: String) async throws {
    try await requestUnAuthorizableAPI(
      api: LogInAPI.findId(email: email),
      responseType: SuccessResponseDTO.self
    )
  }
  
  func requestTemporaryPassword(email: String, userName: String) async throws {
    let requestDTO = dataMapper.mapToFindPasswordRequestDTO(userEmail: email, userName: userName)
    
    try await requestUnAuthorizableAPI(
      api: LogInAPI.findPassword(dto: requestDTO),
      responseType: SuccessResponseDTO.self
    )
  }
  
  func updatePassword(from password: String, newPassword: String) async throws {
    let requestDTO = UpdatePasswordRequstDTO(password: password, newPassword: newPassword)
    
    try await requestAuthorizableAPI(
      api: LogInAPI.updatePassword(dto: requestDTO),
      responseType: SuccessResponseDTO.self
    )
  }
}

// MARK: - Private Methods
private extension LogInRepositoryImpl {
  @discardableResult
  func requestAuthorizableAPI<T: Decodable>(
    api: LogInAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    do {
      let provider = Provider<LogInAPI>(
        stubBehavior: behavior,
        session: .init(interceptor: AuthenticationInterceptor())
      )
      
      let result = try await provider.request(api, type: responseType.self)
      if (200..<300).contains(result.statusCode), let data = result.data {
        return data
      } else if result.statusCode == 401 {
        throw APIError.loginFailed(reason: .invalidEmailOrPassword)
      } else if result.statusCode == 403 {
        throw APIError.authenticationFailed
      } else {
        throw APIError.serverError
      }
    } catch {
      if case NetworkError.networkFailed(reason: .interceptorMapping) = error {
        throw APIError.authenticationFailed
      } else {
        throw error
      }
    }
  }
  
  @discardableResult
  func requestUnAuthorizableAPI<T: Decodable>(
    api: LogInAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    let provider = Provider<LogInAPI>(stubBehavior: behavior)
    let result = try await provider.request(api, type: responseType.self)
    
    if (200..<300).contains(result.statusCode), let data = result.data {
      return data
    } else if result.statusCode == 401 {
      throw APIError.loginFailed(reason: .invalidEmailOrPassword)
    } else if result.statusCode == 404 {
      throw APIError.userNotFound
    } else {
      throw APIError.serverError
    }
  }
}
