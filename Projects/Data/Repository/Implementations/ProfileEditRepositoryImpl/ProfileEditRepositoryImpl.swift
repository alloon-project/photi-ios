//
//  ProfileEditRepositoryImpl.swift
//  DTO
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import DTO
import Entity
import Repository
import PhotiNetwork

public struct ProfileEditRepositoryImpl: ProfileEditRepository {
  private let dataMapper: ProfileEditDataMapper
  
  public init(dataMapper: ProfileEditDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func userInfo() -> Single<ProfileEditInfo> {
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(
              ProfileEditAPI.userInfo,
              type: ProfileEditResponseDTO.self
            ).value
          
          if result.statusCode == 200, let responseDTO = result.data {
            single(.success(dataMapper.mapToProfileEditInfo(responseDTO: responseDTO)))
          } else if result.statusCode == 401 {
            single(.failure(APIError.tokenUnauthenticated))
          } else if result.statusCode == 403 {
            single(.failure(APIError.tokenUnauthorized))
          } else if result.statusCode == 404 {
            single(.failure(APIError.userNotFound))
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
