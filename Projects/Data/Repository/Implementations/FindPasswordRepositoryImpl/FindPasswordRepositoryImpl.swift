//
//  FindPasswordRepositoryImpl.swift
//  Data
//
//  Created by wooseob on 11/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity
import Repository
import PhotiNetwork

public struct FindPasswordRepositoryImpl: FindPasswordRepository {
  private let dataMapper: FindPasswordDataMapper
  
  public init(dataMapper: FindPasswordDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func findPassword(userEmail: String, userName: String) -> RxSwift.Single<Void> {
    let requestDTO = dataMapper.mapToFindPasswordRequestDTO(userEmail: userEmail, userName: userName)
    
        return Single.create { single in
          Task {
            do {
              let result = try await Provider(stubBehavior: .never)
                .request(FindPasswordAPI.findPassword(dto: requestDTO)).value
    
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
