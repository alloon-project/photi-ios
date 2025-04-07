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
  
  public func logIn(userName: String, password: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToLogInRequestDTO(userName: userName, password: password)
      
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(LogInAPI.login(dto: requestDTO), type: LogInResponseDTO.self).value
          if result.statusCode == 200, let data = result.data {
            ServiceConfiguration.shared.setUseName(data.username)
            single(.success(()))
          } else if result.statusCode == 401 {
            single(.failure(APIError.loginFailed(reason: .invalidEmailOrPassword)))
          } else if result.statusCode == 409 {
            single(.failure(APIError.loginFailed(reason: .deletedUser)))
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
