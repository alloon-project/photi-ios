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
    return requestUnAuthorizableAPI(
      api: ChallengeAPI.popularChallenges,
      responseType: [PopularChallengeResponseDTO].self
    )
    .map { $0.map { dataMapper.mapToChallengeDetail(dto: $0) } }
  }
  
  public func fetchEndedChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.endedChallenges(page: page, size: size),
      responseType: EndedChallengeResponseDTO.self
    )
    .map { dataMapper.mapToChallengeSummary(dto: $0) }
  }
  
  public func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail> {
    return requestUnAuthorizableAPI(
      api: ChallengeAPI.challengeDetail(id: id),
      responseType: ChallengeDetailResponseDTO.self,
      behavior: .immediate
    )
    .map { dataMapper.mapToChallengeDetail(dto: $0, id: id) }
  }
  
  public func joinPrivateChallnege(id: Int, code: String) -> Single<Void> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.joinPrivateChallenge(id: id, code: code),
      responseType: SuccessResponseDTO.self,
      behavior: .immediate
    )
    .map { _ in () }
  }
}

// MARK: - Private Methods
private extension ChallengeRepositoryImpl {
  func requestAuthorizableAPI<T: Decodable>(
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .immediate
  ) -> Single<T> {
    return Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(stubBehavior: behavior)
          
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if result.statusCode == 200, let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(APIError.challengeFailed(reason: .invalidInvitationCode)))
          } else if result.statusCode == 401 {
            single(.failure(APIError.tokenUnauthenticated))
          } else if result.statusCode == 403 {
            single(.failure(APIError.tokenUnauthorized))
          } else if result.statusCode == 404 {
            single(.failure(APIError.challengeFailed(reason: .challengeNotFound)))
          } else if result.statusCode == 409 {
            single(.failure(APIError.challengeFailed(reason: .alreadyJoinedChallenge)))
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
  
  func requestUnAuthorizableAPI<T: Decodable>(
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .immediate
  ) -> Single<T> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(stubBehavior: behavior)
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if result.statusCode == 200, let data = result.data {
            single(.success(data))
          } else if result.statusCode == 404 {
            single(.failure(APIError.challengeFailed(reason: .challengeNotFound)))
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
