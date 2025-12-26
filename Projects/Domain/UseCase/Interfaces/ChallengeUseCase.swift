//
//  ChallengeUseCase.swift
//  Entity
//
//  Created by jung on 1/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Entity

public protocol ChallengeUseCase {
  func isLogIn() async throws -> Bool
  func fetchChallengeDetail(id: Int) async throws -> ChallengeDetail
  func fetchChallengeDescription(id: Int) async throws -> ChallengeDescription
  func fetchChallengeMembers(challengeId: Int) async throws -> [ChallengeMember]
  func challengeProveMemberCount(challengeId: Int) async throws -> Int
  
  func isPossibleToJoinChallenge() async -> Bool
  func isProve(challengeId: Int) async throws -> Bool
  func isJoinedChallenge(id: Int) async -> Bool
  func uploadChallengeFeedProof(id: Int, imageData: Data, type: String) async throws -> Feed
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws
  func fetchFeeds(
    id: Int,
    page: Int,
    size: Int,
    orderType: ChallengeFeedsOrderType
  ) async throws -> PageState<[Feed]>
  func fetchInvitationCode(id: Int) async throws -> ChallengeInvitation
  func verifyInvitationCode(id: Int, code: String) async throws -> Bool
  func joinChallenge(id: Int, goal: String) async throws
  func updateChallengeGoal(_ goal: String, challengeId: Int) async throws
  func leaveChallenge(id: Int) async throws
}
