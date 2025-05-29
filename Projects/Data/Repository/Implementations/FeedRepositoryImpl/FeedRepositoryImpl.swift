//
//  FeedRepositoryImpl.swift
//  DTO
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
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
    
    let value = try await requestAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<FeedsResponseDTO>.self
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
  
  func fetchFeed(challengeId: Int, feedId: Int) async throws -> Feed {
    let api = FeedAPI.feedDetail(challengeId: challengeId, feedId: feedId)
    let result = try await requestAuthorizableAPI(
      api: api,
      responseType: FeedDetailResponseDTO.self
    ).value
    
    return dataMapper.mapToFeed(dto: result, id: challengeId)
  }
  
  func fetchFeedComments(
    feedId: Int,
    page: Int,
    size: Int
  ) async throws -> (feeds: [FeedComment], isLast: Bool) {
    let api = FeedAPI.feedComments(feedId: feedId, page: page, size: size)
    let result = try await requestAuthorizableAPI(
      api: api,
      responseType: PaginationResponseDTO<FeedCommentResponseDTO>.self
    ).value
    
    let feeds = result.content.map { dataMapper.mapToFeedComment(dto: $0) }
    
    return (feeds, result.last)
  }
  
  func fetchFeedHistory(page: Int, size: Int) -> Single<[FeedHistory]> {
    return requestAuthorizableAPI(
      api: FeedAPI.feedHistory(page: page, size: size),
      responseType: FeedHistoryResponseDTO.self,
      behavior: .immediate
    )
    .map { dataMapper.mapToFeedHistory(dto: $0) }
  }
}

// MARK: - Update Methods
public extension FeedRepositoryImpl {
  func uploadFeedComment(challengeId: Int, feedId: Int, comment: String) async throws -> Int {
    do {
      let api = FeedAPI.uploadFeedComment(challengeId: challengeId, feedId: feedId, comment: comment)
      let result = try await requestAuthorizableAPI(api: api, responseType: IDResponseDTO.self).value
      return result.id
    } catch {
      throw error
    }
  }
  
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws {
    let api = FeedAPI.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
    let single = requestAuthorizableAPI(api: api, responseType: SuccessResponseDTO.self)
    try await executeSingle(single)
  }
}

// MARK: - Delete Methods
public extension FeedRepositoryImpl {
  func deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int) async throws {
    let api = FeedAPI.deleteFeedComment(challengeId: challengeId, feedId: feedId, commentId: commentId)
    let single = requestAuthorizableAPI(api: api, responseType: SuccessResponseDTO.self)
    try await executeSingle(single)
  }
  
  func deleteFeed(challengeId: Int, feedId: Int) -> Single<Void> {
    return requestAuthorizableAPI(
      api: .deleteFeed(challengeId: challengeId, feedId: feedId),
      responseType: SuccessResponseDTO.self
    )
    .map { _ in }
  }
}

// MARK: - Private Methods
private extension FeedRepositoryImpl {
  func requestAuthorizableAPI<T: Decodable>(
    api: FeedAPI,
    responseType: T.Type,
    behavior: StubBehavior = .never
  ) -> Single<T> {
    return Single.create { single in
      Task {
        do {
          let provider = Provider<FeedAPI>(
            stubBehavior: behavior,
            session: .init(interceptor: AuthenticationInterceptor())
          )
          
          let result = try await provider.request(api, type: responseType.self).value
          if (200..<300).contains(result.statusCode), let data = result.data {
            single(.success(data))
          } else if result.statusCode == 400 {
            single(.failure(APIError.challengeFailed(reason: .invalidInvitationCode)))
          } else if result.statusCode == 401 || result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          } else if result.statusCode == 404 {
            single(.failure(map404ToAPIError(result.code, result.message)))
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
  
  @discardableResult
  func executeSingle<T>(_ single: Single<T>) async throws -> T {
    return try await single.value
  }
}
