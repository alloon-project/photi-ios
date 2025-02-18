//
//  ChallengeRepository.swift
//  Entity
//
//  Created by jung on 10/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Entity

public protocol ChallengeRepository {
  func fetchPopularChallenges() -> Single<[ChallengeDetail]>
  func fetchEndedChallenges(page: Int, size: Int) -> Single<[ChallengeSummary]>
  func fetchChallengeDetail(id: Int) -> Single<ChallengeDetail>
  func joinPrivateChallnege(id: Int, code: String) -> Single<Void>
}
