//
//  ChallengeRepository.swift
//  Entity
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
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

public protocol ChallengeRepository {
  func fetchPopularChallenges() -> Single<[ChallengeDetail]>
  func fetchEndedChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]>
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail>
  func joinPublicChallenge(id: Int) -> Single<Void>
  func joinPrivateChallnege(id: Int, code: String) -> Single<Void>
  func uploadChallengeFeedProof(id: Int, image: Data, imageType: String) async throws
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws
  func isProve(challengeId: Int) async throws -> Bool
  func fetchFeeds(
    id: Int,
    page: Int,
    size: Int,
    orderType: ChallengeFeedsOrderType
  ) async throws -> FeedReturnType
  func fetchFeed(challengeId: Int, feedId: Int) async throws -> Feed
  func fetchFeedComments(
    feedId: Int,
    page: Int,
    size: Int
  ) async throws -> (feeds: [FeedComment], isLast: Bool)
  func uploadFeedComment(challengeId: Int, feedId: Int, comment: String) async throws -> Int
  func deleteFeedComment(challengeId: Int, feedId: Int, commentId: Int) async throws
  func updateChallengeGoal(_ goal: String, challengeId: Int) -> Single<Void>
  func fetchMyChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]>
  func fetchChallengeDescription(challengeId: Int) -> Single<ChallengeDescription>
  func fetchChallengeMembers(challengeId: Int) -> Single<[ChallengeMember]>
}
