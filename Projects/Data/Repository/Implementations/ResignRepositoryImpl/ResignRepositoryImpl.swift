//
//  ResignRepositoryImpl.swift
//  Data
//
//  Created by 임우섭 on 2/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity
import Repository
import PhotiNetwork

public struct ResignRepositoryImpl: ResignRepository {
  private let dataMapper: ResignDataMapper
  
  public init(dataMapper: ResignDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func resign(
    password: String
  ) -> Single<Void> {
    let requestDTO = dataMapper.mapToResignRequestDTO(userPassword: password)
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(ResignAPI.resign(dto: requestDTO)).value
          
          if result.statusCode == 200 {
            single(.success(()))
          } else if result.statusCode == 400 {
            single(.failure(APIError.myPageFailed(reason: .passwordMatchInvalid)))
          } else if result.statusCode == 401 || result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          }
        } catch {
          single(.failure(error))
        }
      }
      
      return Disposables.create()
    }
  }
}
