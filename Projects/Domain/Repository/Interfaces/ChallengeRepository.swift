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
  func fetchEndedChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]>
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail>
  func joinPublicChallenge(id: Int) -> Single<Void>
  func joinPrivateChallnege(id: Int, code: String) -> Single<Void>
  func uploadChallengeFeedProof(id: Int, image: Data, imageType: String) async throws -> Feed
  func isProve(challengeId: Int) async throws -> Bool
  func challengeProveMemberCount(challengeId: Int) async throws -> Int
  func challengeCount() async throws -> Int
  func updateChallengeGoal(_ goal: String, challengeId: Int) -> Single<Void>
  func fetchMyChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]>
  func fetchChallengeDescription(challengeId: Int) -> Single<ChallengeDescription>
  func fetchChallengeMembers(challengeId: Int) -> Single<[ChallengeMember]>
  func leaveChallenge(id: Int) -> Single<Void>
}
