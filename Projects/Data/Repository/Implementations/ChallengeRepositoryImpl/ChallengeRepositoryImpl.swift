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
  
  public func fetchPopularChallenges() -> Single<[Challenge]> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(stubBehavior: .immediate, session: Session())
          let result = try await provider
            .request(ChallengeAPI.popularChallenges, type: [ChallengeResponseDTO].self).value
          
          if result.statusCode == 200, let data = result.data {
            let challenges = data.map { dataMapper.mapToChallenge(dto: $0) }
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
}
