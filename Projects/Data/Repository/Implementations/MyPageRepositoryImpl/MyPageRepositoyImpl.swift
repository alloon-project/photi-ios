//
//  MyPageRepositoyImpl.swift
//  Data
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import DTO
import Entity
import Repository
import PhotiNetwork

public struct MyPageRepositoyImpl: MyPageRepository {
  private let dataMapper: MyPageDataMapper
  
  public init(dataMapper: MyPageDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func userChallengeHistory() -> Single<UserChallengeHistory> {
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(
              MyPageAPI.userChallegeHistory,
              type: UserChallengeHistoryResponseDTO.self
            ).value
          
          if result.statusCode == 200, let responseDTO = result.data {
            single(.success(dataMapper.mapToUserChallengeHistory(responseDTO: responseDTO)))
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
