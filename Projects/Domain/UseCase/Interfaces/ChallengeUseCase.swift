//
//  ChallengeUseCase.swift
//  Entity
//
//  Created by jung on 1/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import Core
import Entity

public enum PageFeeds {
  case `defaults`([[Feed]])
  case lastPage([[Feed]])
}

public protocol ChallengeUseCase {
  var challengeProveMemberCount: Infallible<Int> { get }
  
  func isLogIn() async throws -> Bool
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail>
  func joinPrivateChallnege(id: Int, code: String) async throws
  func joinPublicChallenge(id: Int) -> Single<Void>
  func isProve(challengeId: Int) async throws -> Bool
  func uploadChallengeFeedProof(id: Int, image: UIImageWrapper) async throws
  func updateLikeState(challengeId: Int, feedId: Int, isLike: Bool) async throws
  func fetchFeeds(
    id: Int,
    page: Int,
    size: Int,
    orderType: ChallengeFeedsOrderType
  ) async throws -> PageFeeds
  func updateChallengeGoal(_ goal: String, challengeId: Int) -> Single<Void>
  func fetchChallengeDescription(id: Int) -> Single<ChallengeDescription>
  func fetchChallengeMembers(challengeId: Int) -> Single<[ChallengeMember]>
  func leaveChallenge(id: Int) -> Single<Void>
  func fetchChallengeSampleImages() -> Single<[String]>
  func organizeChallenge() -> Single<Void>
}
