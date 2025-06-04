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
  func logIn(userName: String, password: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToLogInRequestDTO(userName: userName, password: password)
    
    return requestUnAuthorizableAPI(
      api: LogInAPI.login(dto: requestDTO),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in () }
  }
  
  func findId(userEmail: String) -> Single<Void> {
    return requestUnAuthorizableAPI(
      api: LogInAPI.findId(email: userEmail),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in () }
  }
  
  func findPassword(userEmail: String, userName: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToFindPasswordRequestDTO(userEmail: userEmail, userName: userName)
    
    return requestUnAuthorizableAPI(
      api: LogInAPI.findPassword(dto: requestDTO),
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
}
