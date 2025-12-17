//
//  HomeUseCase.swift
//  UseCase
//
//  Created by jung on 10/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import Entity

public protocol HomeUseCase {
  func challengeCount() async throws -> Int
  func fetchPopularChallenge() async throws -> [ChallengeDetail]
  func fetchMyChallenges() async throws -> [ChallengeSummary]
  func uploadChallengeFeed(challengeId: Int, imageData: Data, type: String) async throws -> Feed
}
