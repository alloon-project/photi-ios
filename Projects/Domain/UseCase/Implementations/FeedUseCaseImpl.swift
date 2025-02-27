//
//  FeedUseCaseImpl.swift
//  UseCaseImpl
//
//  Created by jung on 2/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Entity
import Repository
import UseCase

public struct FeedUseCaseImpl: FeedUseCase {
  private let repository: ChallengeRepository
  
  public init(repository: ChallengeRepository) {
    self.repository = repository
  }
  
  public func fetchFeed(challengeId: Int, feedId: Int) async throws -> Feed {
    return try await repository.fetchFeed(challengeId: challengeId, feedId: feedId)
  }
  
  public func isLike(challengeId: Int, feedId: Int) async -> Bool {
    guard let feed = try? await repository.fetchFeed(challengeId: challengeId, feedId: feedId) else {
      return false
    }
    
    return feed.isLike
  }
  
  public func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async {
    try? await repository.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
  }
  
  public func fetchFeedComments(feedId: Int, page: Int, size: Int) async throws -> FeedCommentsPage {
    let (feeds, isLast) = try await repository.fetchFeedComments(
      feedId: feedId,
      page: page,
      size: size
    )
    
    return isLast ? .lastPage(feeds) : .default(feeds)
  }
}
