//
//  FeedRepositoryImpl.swift
//  DTO
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import DataMapper
import DTO
import Entity
import PhotiNetwork
import Repository

public struct FeedRepositoryImpl: FeedRepository {
  private let dataMapper: ChallengeDataMapper
  
  public init(dataMapper: ChallengeDataMapper) {
    self.dataMapper = dataMapper
  }
}

// MARK: - Fetch Methods
public extension FeedRepositoryImpl {
  func fetchFeeds(
    id: Int,
    page: Int,
    size: Int,
    orderType: ChallengeFeedsOrderType
  ) async throws -> FeedReturnType {
    let api = FeedAPI.feeds(
      id: id,
      page: page,
      size: size,
      sortOrder: orderType.rawValue
    )
    
    let dto = try await requestAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<FeedsResponseDTO>.self
    )
    
    let feeds = dto.content.map { data in
      data.feeds.map { dataMapper.mapToFeed(dto: $0) }
    }
    
    return .init(
      feeds: feeds,
      isLast: dto.last,
      memberCount: dto.content.first?.feedMemberCnt ?? 0
    )
  }
  
  func fetchFeed(challengeId: Int, feedId: Int) async throws -> Feed {
    let api = FeedAPI.feedDetail(challengeId: challengeId, feedId: feedId)
    let dto = try await requestAuthorizableAPI(
      api: api,
      responseType: FeedDetailResponseDTO.self
    )
    
    return dataMapper.mapToFeed(dto: dto, id: challengeId)
  }
  
  func fetchFeedComments(
    feedId: Int,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<FeedComment> {
    let api = FeedAPI.feedComments(feedId: feedId, page: page, size: size)
    let dto = try await requestAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<FeedCommentResponseDTO>.self
    )
    
    let feeds = dto.content.map { dataMapper.mapToFeedComment(dto: $0) }
    
    return .init(contents: feeds, isLast: dto.last)
  }
}

// MARK: - Update Methods
public extension FeedRepositoryImpl {
  func uploadFeedComment(challengeId: Int, feedId: Int, comment: String) async throws -> Int {
    let api = FeedAPI.uploadFeedComment(challengeId: challengeId, feedId: feedId, comment: comment)
    return try await requestAuthorizableAPI(api: api, responseType: IDResponseDTO.self).id
  }
  
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws {
    let api = FeedAPI.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
    try await requestAuthorizableAPI(api: api, responseType: SuccessResponseDTO.self)
  }
}

// MARK: - Delete Methods
public extension FeedRepositoryImpl {
  func deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int) async throws {
    let api = FeedAPI.deleteFeedComment(challengeId: challengeId, feedId: feedId, commentId: commentId)
    try await requestAuthorizableAPI(api: api, responseType: SuccessResponseDTO.self)
  }
  
  func deleteFeed(challengeId: Int, feedId: Int) async throws {
    try await requestAuthorizableAPI(
      api: .deleteFeed(challengeId: challengeId, feedId: feedId),
      responseType: SuccessResponseDTO.self
    )
  }
}

// MARK: - Private Methods
private extension FeedRepositoryImpl {
  @discardableResult
  func requestAuthorizableAPI<T: Decodable>(
    api: FeedAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) async throws -> T {
    do {
      let provider = Provider<FeedAPI>(
        stubBehavior: behavior,
        session: .init(interceptor: AuthenticationInterceptor())
      )
      
      let result = try await provider.request(api, type: responseType.self)
      if (200..<300).contains(result.statusCode), let data = result.data {
        return data
      } else if result.statusCode == 401 || result.statusCode == 403 {
        throw APIError.authenticationFailed
      } else if result.statusCode == 404 {
        throw map404ToAPIError(result.code, result.message)
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
    
    func map404ToAPIError(_ code: String, _ message: String) -> APIError {
      if code == "USER_NOT_FOUND" {
        return APIError.challengeFailed(reason: .userNotFound)
      } else if code == "CHALLENGE_NOT_FOUND" {
        return APIError.challengeFailed(reason: .challengeNotFound)
      } else if code == "CHALLENGE_MEMBER_NOT_FOUND" {
        return APIError.challengeFailed(reason: .notChallengeMemeber)
      } else if code == "FEED_COMMENT_NOT_FOUND" {
        return APIError.challengeFailed(reason: .feedCommentNotFound)
      } else if code == "FEED_NOT_FOUND" {
        return APIError.challengeFailed(reason: .feedNotFound)
      } else {
        return APIError.clientError(code: code, message: message)
      }
    }
  }
}
