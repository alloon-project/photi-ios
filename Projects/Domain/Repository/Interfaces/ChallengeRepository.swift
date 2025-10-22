//
//  ChallengeRepository.swift
//  Entity
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Entity

public protocol ChallengeRepository {
  func fetchPopularChallenges() async throws -> [ChallengeDetail]
  func fetchChallengeDetail(id: Int) async throws -> ChallengeDetail
  func fetchMyChallenges(page: Int, size: Int) async throws -> [ChallengeSummary]
  func fetchChallengeDescription(challengeId: Int) async throws -> ChallengeDescription
  func fetchChallengeMembers(challengeId: Int) async throws -> [ChallengeMember]
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
  func fetchPopularHashTags() async throws -> [String]
  func isProve(challengeId: Int) async throws -> Bool
  func challengeProveMemberCount(challengeId: Int) async throws -> Int
  func challengeCount() async throws -> Int
  
  func fetchInvitationCode(id: Int) async throws -> ChallengeInvitation
  func verifyInvitationCode(id: Int, code: String) async throws -> Bool
  func joinChallenge(id: Int, goal: String) async throws
  func updateChallengeGoal(_ goal: String, challengeId: Int) async throws
  func leaveChallenge(id: Int) async throws
  func uploadChallengeFeedProof(id: Int, image: Data, imageType: String) async throws -> Feed
}
