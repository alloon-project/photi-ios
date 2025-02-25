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
import Entity

public enum PageFeeds {
  case `defaults`([[Feed]])
  case lastPage([[Feed]])
}

public protocol ChallengeUseCase {
  var challengeProveMemberCount: Infallible<Int> { get }
  
  func isLogIn() async -> Bool
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail>
  func joinPrivateChallnege(id: Int, code: String) async throws
  func isProof() async -> Bool
  func uploadChallengeFeedProof(id: Int, image: Data) async throws
  func fetchFeeds(
    id: Int,
    page: Int,
    size: Int,
    orderType: ChallengeFeedsOrderType
  ) async throws -> PageFeeds
}
