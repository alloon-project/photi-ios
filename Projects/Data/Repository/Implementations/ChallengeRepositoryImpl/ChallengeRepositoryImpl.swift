//
//  ChallengeRepositoryImpl.swift
//  DTO
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
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
  
  public func fetchFeeds(
    id: Int,
    page: Int,
    size: Int,
    orderType: ChallengeFeedsOrderType
  ) async throws -> FeedReturnType {
    let api = ChallengeAPI.feeds(
      id: id,
      page: page,
      size: size,
      sortOrder: orderType.rawValue
    )
    
    let value = try await requestAuthorizableAPI(
      api: api,
      responseType: FeedsResponseDTO.self,
      behavior: .immediate
    ).value
    
    let feeds = value.content.map { data in
      data.feeds.map { dataMapper.mapToFeed(dto: $0) }
    }
    
    return .init(
      feeds: feeds,
      isLast: value.last,
      memberCount: value.content.first?.feedMemberCnt ?? 0
    )
  }
  
  public func uploadChallengeFeedProof(id: Int, image: Data, imageType: String) async throws {
    let api = ChallengeAPI.uploadChallengeProof(id: id, image: image, imageType: imageType)
    let provider = Provider<ChallengeAPI>(
      stubBehavior: .immediate,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    
    guard let result = try? await provider.request(api).value else {
      throw APIError.serverError
    }
    
    if result.statusCode == 401 || result.statusCode == 403 {
      throw APIError.authenticationFailed
    } else if result.statusCode == 404 {
      throw APIError.userNotFound
    } else if result.statusCode == 409 {
      throw APIError.challengeFailed(reason: .alreadyUploadFeed)
    }
  }
  
  public func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws {
    let api = ChallengeAPI.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
    let provider = Provider<ChallengeAPI>(
      stubBehavior: .immediate,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    
    guard let result = try? await provider.request(api).value else {
      throw APIError.serverError
    }
    
    if result.statusCode == 401 || result.statusCode == 403 {
      throw APIError.authenticationFailed
    } else if result.statusCode == 404 {
      throw APIError.userNotFound
    }
  }
  
  public func isProve(challengeId: Int) async throws -> Bool {
    let api = ChallengeAPI.isProve(challengeId: challengeId)
    let result = try await requestAuthorizableAPI(
      api: api,
      responseType: ChallengeProveResponseDTO.self,
      behavior: .immediate
    ).value
    
    return result.isProve
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
          let provider = Provider<ChallengeAPI>(
            stubBehavior: behavior,
            session: .init(interceptor: AuthenticationInterceptor())
          )
          
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(APIError.challengeFailed(reason: .invalidInvitationCode)))
          } else if result.statusCode == 401 || result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
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
          
          if (200..<300).contains(result.statusCode), let data = result.data {
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
