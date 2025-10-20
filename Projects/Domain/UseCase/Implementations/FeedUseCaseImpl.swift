//
//  FeedUseCaseImpl.swift
//  UseCaseImpl
//
//  Created by jung on 2/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity
import Repository
import UseCase

public struct FeedUseCaseImpl: FeedUseCase {
  private let repository: FeedRepository
  
  public init(repository: FeedRepository) {
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
  
  public func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws {
    try await repository.updateLikeState(challengeId: challengeId, feedId: feedId, isLike: isLike)
  }
  
  public func fetchFeedComments(feedId: Int, page: Int, size: Int) async throws -> PageState<FeedComment> {
    let result = try await repository.fetchFeedComments(
      feedId: feedId,
      page: page,
      size: size
    )
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  public func uploadFeedComment(challengeId: Int, feedId: Int, comment: String) async throws -> Int {
    return try await repository.uploadFeedComment(challengeId: challengeId, feedId: feedId, comment: comment)
  }
  
  public func deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int) async throws {
    try await repository.deleteFeedComment(challengeId: challengeId, feedId: feedId, commentId: commentId)
  }
  
  public func deleteFeed(challengeId: Int, feedId: Int) -> Single<Void> {
    asyncToSingle { 
      return try await repository.deleteFeed(challengeId: challengeId, feedId: feedId)
    }
  }
}

// MARK: - Private Methods
private extension FeedUseCaseImpl {
  func asyncToSingle<T>(_ work: @escaping () async throws -> T) -> Single<T> {
    Single.create { single in
      let task = Task {
        do {
          single(.success(try await work()))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create { task.cancel() }
    }
  }
}
