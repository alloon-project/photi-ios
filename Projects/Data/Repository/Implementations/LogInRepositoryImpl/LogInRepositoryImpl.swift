//
//  LogInRepositoryImpl.swift
//  DTO
//
//  Created by jung on 8/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import DataMapper
import Entity
import Repository
import PhotiNetwork

import DTO

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
          let result = try await Provider(stubBehavior: .delayed(seconds: 1))
            .request(LogInAPI.login(dto: requestDTO)).value
          
          if result.statusCode == 200 {
            single(.success(()))
          } else {
            single(.failure(APIError.loginFailed))
          }
        } catch {
          single(.failure(error))
        }
      }
      
      return Disposables.create()
    }
  }
}
