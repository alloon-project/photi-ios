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
  
  func fetchFeed(challengeId: Int, feedId: Int) async throws -> Feed {
    let api = FeedAPI.feedDetail(challengeId: challengeId, feedId: feedId)
    let result = try await requestAuthorizableAPI(
      api: api,
      responseType: FeedDetailResponseDTO.self,
      behavior: .immediate
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
      responseType: FeedCommentsResponseDTO.self,
      behavior: .immediate
    ).value
    
    let feeds = result.content.map { dataMapper.mapToFeedComment(dto: $0) }
    
    return (feeds, result.last)
  }
}

// MARK: - Update Methods
public extension FeedRepositoryImpl {
  func uploadFeedComment(challengeId: Int, feedId: Int, comment: String) async throws -> Int {
    let api = FeedAPI.uploadFeedComment(challengeId: challengeId, feedId: feedId, comment: comment)
    let provider = Provider<FeedAPI>(
      stubBehavior: .immediate,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    
    guard let result = try? await provider.request(api, type: FeedCommentResponseDTO.self).value else {
      throw APIError.serverError
    }
    
    if result.statusCode == 401 || result.statusCode == 403 {
      throw APIError.authenticationFailed
    } else if result.statusCode == 404 {
      throw APIError.challengeFailed(reason: .challengeNotFound)
    }
    
    guard let id = result.data?.id else { throw APIError.serverError }
    return id
  }
  
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws {
    let api = FeedAPI.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
    let provider = Provider<FeedAPI>(
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
}

// MARK: - Delete Methods
public extension FeedRepositoryImpl {
  func deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int) async throws {
    let api = FeedAPI.deleteFeedComment(challengeId: challengeId, feedId: feedId, commentId: commentId)
    let provider = Provider<FeedAPI>(
      stubBehavior: .immediate,
      session: .init(interceptor: AuthenticationInterceptor())
    )
    
    guard let result = try? await provider.request(api).value else {
      throw APIError.serverError
    }
    
    if result.statusCode == 401 || result.statusCode == 403 {
      throw APIError.authenticationFailed
    } else if result.statusCode == 404 {
      throw APIError.challengeFailed(reason: .challengeNotFound)
    }
  }
}

// MARK: - Private Methods
private extension FeedRepositoryImpl {
  func requestAuthorizableAPI<T: Decodable>(
    api: FeedAPI,
    responseType: T.Type,
    behavior: StubBehavior = .immediate
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
    api: FeedAPI,
    responseType: T.Type,
    behavior: StubBehavior = .immediate
  ) -> Single<T> {
    Single.create { single in
      Task {
        do {
          let provider = Provider<FeedAPI>(stubBehavior: behavior)
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
