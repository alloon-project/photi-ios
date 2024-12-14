//
//  EndedChallengeRepositoryImpl.swift
//  Data
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import DTO
import Entity
import Repository
import PhotiNetwork

public struct EndedChallengeRepositoryImpl: EndedChallengeRepository {
  private let dataMapper: EndedChallengeDataMapper
  
  public init(dataMapper: EndedChallengeDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func endedChallenges(page: Int, size: Int) -> Single<[EndedChallenge]> {
    let requestDTO = dataMapper.mapToEndedChallengeRequestDTO(page: page, size: size)
      
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(EndedChallengeAPI.endedChallenges(dto: requestDTO),
                     type: EndedChallengeResponseDTO.self).value
          
          if result.statusCode == 200, let responseDTO = result.data {
            single(.success(dataMapper.mapToEndedChallenge(responseDTO: responseDTO)))
          } else if result.statusCode == 401 {
            single(.failure(APIError.tokenUnauthenticated))
          } else if result.statusCode == 403 {
            single(.failure(APIError.tokenUnauthorized))
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
