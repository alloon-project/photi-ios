//
//  ChallengeUseCase.swift
//  Entity
//
//  Created by jung on 1/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Core
import Entity

public protocol ChallengeUseCase {
  func isLogIn() async throws -> Bool
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail>
  func fetchChallengeDescription(id: Int) -> Single<ChallengeDescription>
  func fetchChallengeMembers(challengeId: Int) -> Single<[ChallengeMember]>
  func challengeProveMemberCount(challengeId: Int) async throws -> Int

  func isPossibleToJoinChallenge() async -> Bool
  func isProve(challengeId: Int) async throws -> Bool
  func isJoinedChallenge(id: Int) async -> Bool
  func uploadChallengeFeedProof(id: Int, image: UIImageWrapper) async throws -> Feed
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws
  func fetchFeeds(
    id: Int,
    page: Int,
    size: Int,
    orderType: ChallengeFeedsOrderType
  ) async throws -> PageState<[Feed]>
  func verifyInvitationCode(id: Int, code: String) async throws -> Bool
  func joinChallenge(id: Int, goal: String) -> Single<Void>
  func updateChallengeGoal(_ goal: String, challengeId: Int) -> Single<Void>
  func leaveChallenge(id: Int) -> Single<Void>
}
