//
//  HomeUseCase.swift
//  UseCase
//
//  Created by jung on 10/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import Core
import Entity

public protocol HomeUseCase {
  func challengeCount() async throws -> Int
  func fetchPopularChallenge() -> Single<[ChallengeDetail]>
  func fetchMyChallenges() -> Single<[ChallengeSummary]>
  func uploadChallengeFeed(challengeId: Int, image: UIImageWrapper) async throws
}
