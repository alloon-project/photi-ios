//
//  ChallengeRepositoryImpl.swift
//  DTO
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
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
  func fetchPopularChallenges() async throws -> [ChallengeDetail] {
    return try await requestUnAuthorizableAPI(
      api: ChallengeAPI.popularChallenges,
      responseType: [PopularChallengeResponseDTO].self
    )
    .map { dataMapper.mapToChallengeDetail(dto: $0) }
  }
  
  func fetchPopularHashTags() async throws -> [String] {
    return try await requestUnAuthorizableAPI(
      api: ChallengeAPI.popularHashTags,
      responseType: [HashTagResponseDTO].self
    )
    .map { $0.hashtag }
  }
  
  func fetchChallengeDetail(id: Int) async throws -> ChallengeDetail {
    let dto = try await requestUnAuthorizableAPI(
      api: ChallengeAPI.challengeDetail(id: id),
      responseType: ChallengeDetailResponseDTO.self
    )
    return dataMapper.mapToChallengeDetail(dto: dto, id: id)
  }
  
  func fetchChallenges(
    byHashTag hashTag: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary> {
    let api = ChallengeAPI.challengesByHashTag(hashTag, page: page, size: size)
    
    let dto = try await requestUnAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<SearchChallengeResponseDTO>.self
    )
    
    let challenges = dataMapper.mapToChallengeSummaryFromSearchChallenge(dto: dto.content)
    return .init(contents: challenges, isLast: dto.last)
  }
  
  func fetchRecentChallenges(page: Int, size: Int) async throws -> PaginationResultType<ChallengeSummary> {
    let api = ChallengeAPI.recentChallenges(page: page, size: size)
    
    let result = try await requestUnAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<SearchChallengeResponseDTO>.self
    )
    
    let challenges = dataMapper.mapToChallengeSummaryFromSearchChallenge(dto: result.content)
    return .init(contents: challenges, isLast: result.last)
  }
  
  func searchChallenge(
    byName name: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary> {
    let api = ChallengeAPI.searchChallengesByName(name, page: page, size: size)
    
    let dto = try await requestUnAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<SearchChallengeByNameResponseDTO>.self
    )
    
    let challenges = dataMapper.mapToChallengeSummaryFromByName(dto.content)
    
    return .init(contents: challenges, isLast: dto.last)
  }
  
  func searchChallenge(
    byHashTag hashtag: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary> {
    let api = ChallengeAPI.searchChallengesByHashtag(hashtag, page: page, size: size)
    
    let dto = try await requestUnAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<SearchChallengeByHashtagResponseDTO>.self
    )
    
    let challenges = dataMapper.mapToChallengeSummaryFromByHashTag(dto.content)
    
    return .init(contents: challenges, isLast: dto.last)
  }
  
  func isProve(challengeId: Int) async throws -> Bool {
    let api = ChallengeAPI.isProve(challengeId: challengeId)
    let dto = try await requestAuthorizableAPI(
      api: api,
      responseType: ChallengeProveResponseDTO.self
    )
    
    return dto.isProve
  }
  
  func challengeCount() async throws -> Int {
    let dto = try await requestAuthorizableAPI(
      api: ChallengeAPI.challengeCount,
      responseType: ChallengeCountResponseDTO.self
    )
    
    return dto.challengeCnt
  }
  
  func challengeProveMemberCount(challengeId: Int) async throws -> Int {
    let dto = try await requestAuthorizableAPI(
      api: ChallengeAPI.challengeProveMemberCount(challengeId: challengeId),
      responseType: ChallengeProveMemberCountResponseDTO.self
    )
    
    return dto.feedMemberCnt
  }
  
  func fetchMyChallenges(page: Int, size: Int) async throws -> [ChallengeSummary] {
    return try await requestAuthorizableAPI(
      api: ChallengeAPI.myChallenges(page: page, size: size),
      responseType: PaginationResponseDTO<MyChallengeResponseDTO>.self
    ).content
    .map { dataMapper.mapToChallengeSummaryFromMyChallenge(dto: $0) }
  }
  
  func fetchChallengeDescription(challengeId: Int) async throws -> ChallengeDescription {
    let dto = try await requestAuthorizableAPI(
      api: ChallengeAPI.challengeDescription(id: challengeId),
      responseType: ChallengeDescriptionResponseDTO.self
    )
    
    return dataMapper.mapToChallengeDescription(dto: dto, id: challengeId)
  }
  
  func fetchChallengeMembers(challengeId: Int) async throws -> [ChallengeMember] {
    return try await requestAuthorizableAPI(
      api: ChallengeAPI.challengeMember(challengeId: challengeId),
      responseType: [ChallengeMemberResponseDTO].self
    )
    .map { dataMapper.mapToChallengeMember(dto: $0) }
  }
  
  func fetchInvitationCode(id: Int) async throws -> ChallengeInvitation {
    let dto = try await requestAuthorizableAPI(
      api: ChallengeAPI.fetchInviitationCode(id: id),
      responseType: FetchInvitaionCodeResponseDTO.self
    )
    
    return dataMapper.mapToChallengeInvitaion(dto: dto)
  }
}

// MARK: - Upload Methods
public extension ChallengeRepositoryImpl {
  func verifyInvitationCode(id: Int, code: String) async throws -> Bool {
    let dto = try await requestUnAuthorizableAPI(
      api: ChallengeAPI.verifyInvitationCode(id: id, code),
      responseType: VerifyInvitationCodeResponseDTO.self
    )
    
    return dto.isMatch
  }
  
  func joinChallenge(id: Int, goal: String) async throws {
    try await requestAuthorizableAPI(
      api: ChallengeAPI.joinChallenge(id: id, goal: goal),
      responseType: SuccessResponseDTO.self
    )
  }
  
  func updateChallengeGoal(_ goal: String, challengeId: Int) async throws {
    try await requestAuthorizableAPI(
      api: ChallengeAPI.updateChallengeGoal(goal, challengeId: challengeId),
      responseType: SuccessResponseDTO.self
    )
  }
  
  func uploadChallengeFeedProof(id: Int, image: Data, imageType: String) async throws -> Feed {
    let api = ChallengeAPI.uploadChallengeProof(id: id, image: image, imageType: imageType)
    
    let dto = try await requestAuthorizableAPI(
      api: api,
      responseType: FeedResponseDTO.self
    )
    
    return dataMapper.mapToFeed(dto: dto)
  }
}

// MARK: - Delete Methods
public extension ChallengeRepositoryImpl {
  func leaveChallenge(id: Int) async throws {
    try await requestAuthorizableAPI(
      api: .leaveChallenge(challengeId: id),
      responseType: SuccessResponseDTO.self
    )
  }
}

// MARK: - Private Methods
private extension ChallengeRepositoryImpl {
  @discardableResult
  func requestAuthorizableAPI<T: Decodable>(
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    do {
      let provider = Provider<ChallengeAPI>(
        stubBehavior: behavior,
        session: .init(interceptor: AuthenticationInterceptor())
      )
      
      let result = try await provider.request(api, type: responseType.self)
      if (200..<300).contains(result.statusCode), let data = result.data {
        return data
      } else if result.statusCode == 400 {
        throw map400ToAPIError(result.code, result.message)
      } else if result.statusCode == 401 || result.statusCode == 403 {
        throw APIError.authenticationFailed
      } else if result.statusCode == 404 {
        throw map404ToAPIError(result.code, result.message)
      } else if result.statusCode == 409 {
        throw map409ToAPIError(result.code, result.message)
      } else if result.statusCode == 413 {
        throw APIError.challengeFailed(reason: .fileTooLarge)
      } else if result.statusCode == 415 {
        throw APIError.challengeFailed(reason: .invalidFileFormat)
      } else {
        throw APIError.serverError
      }
    } catch {
      if case NetworkError.networkFailed(reason: .interceptorMapping) = error {
        throw APIError.authenticationFailed
      } else {
        throw error
      }
    }
  }
  
  @discardableResult
  func requestUnAuthorizableAPI<T: Decodable>(
    api: ChallengeAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    let provider = Provider<ChallengeAPI>(stubBehavior: behavior)
    let result = try await provider
      .request(api, type: responseType.self)
    
    if (200..<300).contains(result.statusCode), let data = result.data {
      return data
    } else if result.statusCode == 400 {
      throw map400ToAPIError(result.code, result.message)
    } else if result.statusCode == 404 {
      throw map404ToAPIError(result.code, result.message)
    } else if result.statusCode == 409 {
      throw map409ToAPIError(result.code, result.message)
    } else if result.statusCode == 413 {
      throw APIError.challengeFailed(reason: .fileTooLarge)
    } else if result.statusCode == 415 {
      throw APIError.challengeFailed(reason: .invalidFileFormat)
    } else {
      throw APIError.serverError
    }
  }
}

// MARK: - Error Mapping
private extension ChallengeRepositoryImpl {
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
}
