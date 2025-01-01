//
//  FindIdRepositoryImpl.swift
//  Data
//
//  Created by 임우섭 on 12/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity
import Repository
import PhotiNetwork

public struct FindIdRepositoryImpl: FindIdRepository {
  private let dataMapper: FindIdDataMapper
  
  public init(dataMapper: FindIdDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func findId(userEmail: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToFindIdRequestDTO(userEmail: userEmail)
    
        return Single.create { single in
          Task {
            do {
              let result = try await Provider(stubBehavior: .never)
                .request(FindIdAPI.findId(dto: requestDTO)).value
    
              if result.statusCode == 200 {
                single(.success(()))
              } else {
                single(.failure(APIError.userNotFound))
              }
            } catch {
              single(.failure(error))
            }
          }
    
          return Disposables.create()
        }
  }
}
