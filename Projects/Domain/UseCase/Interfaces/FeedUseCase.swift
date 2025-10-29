//
//  FeedUseCase.swift
//  UseCase
//
//  Created by jung on 2/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Entity

public protocol FeedUseCase {
  func fetchFeed(challengeId: Int, feedId: Int) async throws -> Feed
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws
  func fetchFeedComments(feedId: Int, page: Int, size: Int) async throws -> PageState<FeedComment>
  func uploadFeedComment(challengeId: Int, feedId: Int, comment: String) async throws -> Int
  func deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int) async throws
  func deleteFeed(challengeId: Int, feedId: Int) async throws -> Void
}
