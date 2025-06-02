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
}

// MARK: - Fetch Methods
public extension ChallengeRepositoryImpl {
  func fetchPopularChallenges() -> Single<[ChallengeDetail]> {
    return requestUnAuthorizableAPI(
      api: ChallengeAPI.popularChallenges,
      responseType: [PopularChallengeResponseDTO].self
    )
    .map { $0.map { dataMapper.mapToChallengeDetail(dto: $0) } }
  }
  
  func fetchPopularHashTags() -> Single<[String]> {
    return requestUnAuthorizableAPI(
      api: ChallengeAPI.popularHashTags,
      responseType: [HashTagResponseDTO].self
    )
    .map { $0.map { $0.hashtag } }
  }
  
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail> {
    return requestUnAuthorizableAPI(
      api: ChallengeAPI.challengeDetail(id: id),
      responseType: ChallengeDetailResponseDTO.self
    )
    .map { dataMapper.mapToChallengeDetail(dto: $0, id: id) }
  }
  
  func fetchChallenges(
    byHashTag hashTag: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary> {
    let api = ChallengeAPI.challengesByHashTag(hashTag, page: page, size: size)
    
    let result = try await requestUnAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<SearchChallengeResponseDTO>.self
    ).value
    
    let challenges = dataMapper.mapToChallengeSummaryFromSearchChallenge(dto: result.content)
    return .init(contents: challenges, isLast: result.last)
  }
  
  func fetchRecentChallenges(page: Int, size: Int) async throws -> PaginationResultType<ChallengeSummary> {
    let api = ChallengeAPI.recentChallenges(page: page, size: size)
    
    let result = try await requestUnAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<SearchChallengeResponseDTO>.self
    ).value
    
    let challenges = dataMapper.mapToChallengeSummaryFromSearchChallenge(dto: result.content)
    return .init(contents: challenges, isLast: result.last)
  }
  
  func searchChallenge(
    byName name: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary> {
    let api = ChallengeAPI.searchChallengesByName(name, page: page, size: size)
    
    let result = try await requestUnAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<SearchChallengeByNameResponseDTO>.self
    ).value
    
    let challenges = dataMapper.mapToChallengeSummaryFromByName(result.content)
    
    return .init(contents: challenges, isLast: result.last)
  }
  
  func searchChallenge(
    byHashTag hashtag: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary> {
    let api = ChallengeAPI.searchChallengesByHashtag(hashtag, page: page, size: size)
    
    let result = try await requestUnAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<SearchChallengeByHashtagResponseDTO>.self
    ).value
    
    let challenges = dataMapper.mapToChallengeSummaryFromByHashTag(result.content)
    
    return .init(contents: challenges, isLast: result.last)
  }
  
  func isProve(challengeId: Int) async throws -> Bool {
    let api = ChallengeAPI.isProve(challengeId: challengeId)
    let result = try await requestAuthorizableAPI(
      api: api,
      responseType: ChallengeProveResponseDTO.self
    ).value
    
    return result.isProve
  }
  
  func challengeCount() async throws -> Int {
    let result = try await requestAuthorizableAPI(
        api: ChallengeAPI.challengeCount,
        responseType: ChallengeCountResponseDTO.self
      ).value
      
    return result.challengeCnt
  }
  
  func challengeProveMemberCount(challengeId: Int) async throws -> Int {
    let result = try await requestAuthorizableAPI(
      api: ChallengeAPI.challengeProveMemberCount(challengeId: challengeId),
      responseType: ChallengeProveMemberCountResponseDTO.self
    ).value
        
    return result.feedMemberCnt
  }
    
  func fetchMyChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.myChallenges(page: page, size: size),
      responseType: PaginationResponseDTO<MyChallengeResponseDTO>.self
    )
    .map { dataMapper.mapToChallengeSummaryFromMyChallenge(dto: $0.content) }
  }
  
  func fetchChallengeDescription(challengeId: Int) -> Single<ChallengeDescription> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.challengeDescription(id: challengeId),
      responseType: ChallengeDescriptionResponseDTO.self
    )
    .map { dataMapper.mapToChallengeDescription(dto: $0, id: challengeId) }
  }
  
  func fetchChallengeMembers(challengeId: Int) -> Single<[ChallengeMember]> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.challengeMember(challengeId: challengeId),
      responseType: [ChallengeMemberResponseDTO].self
    )
    .map { dataMapper.mapToChallengeMembers(dto: $0) }
  }
}

// MARK: - Upload Methods
public extension ChallengeRepositoryImpl {
  func verifyInvitationCode(id: Int, code: String) async throws -> Bool {
    let result = try await requestUnAuthorizableAPI(
      api: ChallengeAPI.verifyInvitationCode(id: id, code),
      responseType: VerifyInvitationCodeResponseDTO.self
    ).value
    
    return result.isMatch
  }
  
  func joinChallenge(id: Int, goal: String) -> Single<Void> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.joinChallenge(id: id, goal: goal),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in () }
  }
  
  func updateChallengeGoal(_ goal: String, challengeId: Int) -> Single<Void> {
    return requestAuthorizableAPI(
      api: ChallengeAPI.updateChallengeGoal(goal, challengeId: challengeId),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in }
  }
  
  func uploadChallengeFeedProof(id: Int, image: Data, imageType: String) async throws -> Feed {
    let api = ChallengeAPI.uploadChallengeProof(id: id, image: image, imageType: imageType)
    
    let result = try await requestAuthorizableAPI(
      api: api,
      responseType: FeedResponseDTO.self
    ).value
    
    return dataMapper.mapToFeed(dto: result) 
  }
}

// MARK: - Delete Methods
public extension ChallengeRepositoryImpl {
  func leaveChallenge(id: Int) -> Single<Void> {
    return requestAuthorizableAPI(
      api: .leaveChallenge(challengeId: id),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in }
  }
}

// MARK: - Private Methods
private extension ChallengeRepositoryImpl {
  func requestAuthorizableAPI<T: Decodable>(
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    return Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(
            stubBehavior: behavior,
            session: .init(interceptor: AuthenticationInterceptor())
          )
          
          let result = try await provider.request(api, type: responseType.self).value
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(map400ToAPIError(result.code, result.message)))
          } else if result.statusCode == 401 || result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          } else if result.statusCode == 404 {
            single(.failure(map404ToAPIError(result.code, result.message)))
          } else if result.statusCode == 409 {
            single(.failure(map409ToAPIError(result.code, result.message)))
          } else if result.statusCode == 413 {
            single(.failure(APIError.challengeFailed(reason: .fileTooLarge)))
          } else if result.statusCode == 415 {
            single(.failure(APIError.challengeFailed(reason: .invalidFileFormat)))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          if case NetworkError.networkFailed(reason: .interceptorMapping) = error {
            single(.failure(APIError.authenticationFailed))
          } else {
            single(.failure(error))
          }
        }
      }
      return Disposables.create()
    }
  }
  
  func requestUnAuthorizableAPI<T: Decodable>(
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<ChallengeAPI>(stubBehavior: behavior)
          let result = try await provider
            .request(api, type: responseType.self).value
          
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(map400ToAPIError(result.code, result.message)))
          } else if result.statusCode == 404 {
            single(.failure(map404ToAPIError(result.code, result.message)))
          } else if result.statusCode == 409 {
            single(.failure(map409ToAPIError(result.code, result.message)))
          } else if result.statusCode == 413 {
            single(.failure(APIError.challengeFailed(reason: .fileTooLarge)))
          } else if result.statusCode == 415 {
            single(.failure(APIError.challengeFailed(reason: .invalidFileFormat)))
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
  
  func map400ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "CHALLENGE_LIMIT_EXCEED" {
      return APIError.challengeFailed(reason: .challengeLimitExceed)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  func map404ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "USER_NOT_FOUND" {
      return APIError.challengeFailed(reason: .userNotFound)
    } else if code == "CHALLENGE_NOT_FOUND" {
      return APIError.challengeFailed(reason: .challengeNotFound)
    } else if code == "CHALLENGE_MEMBER_NOT_FOUND" {
      return APIError.challengeFailed(reason: .notChallengeMemeber)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  func map409ToAPIError(_ code: String, _ message: String) -> APIError {
    if code == "EXISTING_CHALLENGE_MEMBER" {
      return APIError.challengeFailed(reason: .alreadyJoinedChallenge)
    } else if code == "EXISTING_FEED" {
      return APIError.challengeFailed(reason: .alreadyUploadFeed)
    } else {
      return APIError.clientError(code: code, message: message)
    }
  }
  
  @discardableResult
  func executeSingle<T>(_ single: Single<T>) async throws -> T {
    return try await single.value
  }
}
