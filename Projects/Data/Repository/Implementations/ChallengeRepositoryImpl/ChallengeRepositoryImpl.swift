//
//  ChallengeRepositoryImpl.swift
//  DTO
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import DTO
import Entity
import PhotiNetwork
import Repository

public struct ChallengeRepositoryImpl: ChallengeRepository {
  private let dataMapper: ChallengeDataMapper
  
  public init(dataMapper: ChallengeDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func fetchPopularChallenges() -> Single<[ChallengeDetail]> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(stubBehavior: .immediate)
          let result = try await provider
            .request(ChallengeAPI.popularChallenges, type: [PopularChallengeResponseDTO].self).value
          
          if result.statusCode == 200, let data = result.data {
            let challenges = data.map { dataMapper.mapToChallengeDetail(dto: $0) }
            single(.success(challenges))
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
  
  public func fetchEndedChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(stubBehavior: .immediate)
          let api = ChallengeAPI.endedChallenges(page: page, size: size)
          let result = try await provider
            .request(api, type: EndedChallengeResponseDTO.self).value
          
          if result.statusCode == 200, let data = result.data {
            let challenges = dataMapper.mapToChallengeSummary(dto: data)
            single(.success(challenges))
          } else if result.statusCode == 401 {
            single(.failure(APIError.tokenUnauthenticated))
          } else if result.statusCode == 403 {
            single(.failure(APIError.tokenUnauthorized))
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
