//
//  SearchUseCase.swift
//  UseCase
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity

public enum PageSearchChallenges {
  case `defaults`([ChallengeSummary])
  case lastPage([ChallengeSummary])
  
  public var challenges: [ChallengeSummary] {
    switch self {
      case .defaults(let values), .lastPage(let values):
        return values
    }
  }
}

public protocol SearchUseCase {
  func popularChallenges() -> Single<[ChallengeDetail]>
  func popularHashtags() -> Single<[String]>
  func challenges(
    byHashTag hashTag: String,
    page: Int,
    size: Int
  ) async throws -> PageSearchChallenges
  func didJoinedChallenge(id: Int) async throws -> Bool
  func isPossibleToCreateChallenge() async -> Bool
  func recentChallenges(page: Int, size: Int) async throws -> PageSearchChallenges
  func searchChallenge(byName name: String, page: Int, size: Int) async throws -> PageSearchChallenges
}
