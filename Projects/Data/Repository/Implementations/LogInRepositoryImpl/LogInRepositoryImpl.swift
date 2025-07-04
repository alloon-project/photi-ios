//
//  LogInRepositoryImpl.swift
//  DTO
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
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
  func logIn(userName: String, password: String) -> Single<String> {
    let requestDTO = dataMapper.mapToLogInRequestDTO(userName: userName, password: password)
    
    return requestUnAuthorizableAPI(
      api: LogInAPI.login(dto: requestDTO),
      responseType: LogInResponseDTO.self
    )
    .map { $0.username }
  }
  
  func requestUserInformation(email: String) -> Single<Void> {
    return requestUnAuthorizableAPI(
      api: LogInAPI.findId(email: email),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in () }
  }
  
  func requestTemporaryPassword(email: String, userName: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToFindPasswordRequestDTO(userEmail: email, userName: userName)
    
    return requestUnAuthorizableAPI(
      api: LogInAPI.findPassword(dto: requestDTO),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in () }
  }
  
  func updatePassword(from password: String, newPassword: String) -> Single<Void> {
    let requestDTO = UpdatePasswordRequstDTO(password: password, newPassword: newPassword)
    
    return requestAuthorizableAPI(
      api: LogInAPI.updatePassword(dto: requestDTO),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in () }
  }
}

// MARK: - Private Methods
private extension LogInRepositoryImpl {
  func requestUnAuthorizableAPI<T: Decodable>(
    api: LogInAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<LogInAPI>(stubBehavior: behavior)
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 401 {
            single(.failure(APIError.loginFailed(reason: .invalidEmailOrPassword)))
          } else if result.statusCode == 404 {
            single(.failure(APIError.userNotFound))
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
  
  @discardableResult
  func requestAuthorizableAPI<T: Decodable>(
    api: LogInAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    return Single.create { single in
      Task {
        do {
          let provider = Provider<LogInAPI>(
            stubBehavior: behavior,
            session: .init(interceptor: AuthenticationInterceptor())
          )
          
          let result = try await provider.request(api, type: responseType.self).value
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 401 {
            single(.failure(APIError.loginFailed(reason: .invalidEmailOrPassword)))
          } else if result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          if case NetworkError.networkFailed(reason: .interceptorMapping) = error {
            single(.failure(APIError.authenticationFailed))
          } else {
            single(.failure(error))
          }
        }
      }
      return Disposables.create()
    }
  }
}
