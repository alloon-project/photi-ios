//
//  FeedRepository.swift
//  Entity
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity

public struct FeedReturnType {
  public let feeds: [[Feed]]
  public let isLast: Bool
  public let memberCount: Int
  
  public init(feeds: [[Feed]], isLast: Bool, memberCount: Int) {
    self.feeds = feeds
    self.isLast = isLast
    self.memberCount = memberCount
  }
}

public protocol FeedRepository {
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws
  func fetchFeeds(id: Int, page: Int, size: Int, orderType: ChallengeFeedsOrderType) async throws -> FeedReturnType
  func fetchFeed(challengeId: Int, feedId: Int) async throws -> Feed
  func fetchFeedComments(feedId: Int, page: Int, size: Int) async throws -> PaginationResultType<FeedComment>
  func uploadFeedComment(challengeId: Int, feedId: Int, comment: String) async throws -> Int
  func deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int) async throws
  func deleteFeed(challengeId: Int, feedId: Int) -> Single<Void>
  func fetchFeedHistory(page: Int, size: Int) -> Single<[FeedHistory]>
}
