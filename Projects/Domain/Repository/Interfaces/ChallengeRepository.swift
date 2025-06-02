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

public protocol ChallengeRepository {
  func fetchPopularChallenges() -> Single<[ChallengeDetail]>
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail>
  func fetchMyChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]>
  func fetchChallengeDescription(challengeId: Int) -> Single<ChallengeDescription>
  func fetchChallengeMembers(challengeId: Int) -> Single<[ChallengeMember]>
  func fetchChallenges(
    byHashTag hashTag: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary>
  func fetchRecentChallenges(page: Int, size: Int) async throws -> PaginationResultType<ChallengeSummary>
  func searchChallenge(
    byName name: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary>
  func searchChallenge(
    byHashTag hashtag: String,
    page: Int,
    size: Int
  ) async throws -> PaginationResultType<ChallengeSummary>
  func fetchPopularHashTags() -> Single<[String]>
  func isProve(challengeId: Int) async throws -> Bool
  func challengeProveMemberCount(challengeId: Int) async throws -> Int
  func challengeCount() async throws -> Int
  
  func verifyInvitationCode(id: Int, code: String) async throws -> Bool
  func joinChallenge(id: Int, goal: String) -> Single<Void>
  func updateChallengeGoal(_ goal: String, challengeId: Int) -> Single<Void>
  func leaveChallenge(id: Int) -> Single<Void>
  func uploadChallengeFeedProof(id: Int, image: Data, imageType: String) async throws -> Feed
}
