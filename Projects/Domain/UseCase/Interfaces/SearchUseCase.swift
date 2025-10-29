//
//  SearchUseCase.swift
//  UseCase
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Entity

public protocol SearchUseCase {
  func popularChallenges() async throws -> [ChallengeDetail]
  func popularHashtags() async throws -> [String]
  func challenges(
    byHashTag hashTag: String,
    page: Int,
    size: Int
  ) async throws -> PageState<ChallengeSummary>
  func didJoinedChallenge(id: Int) async throws -> Bool
  func isPossibleToCreateChallenge() async -> Bool
  func recentChallenges(page: Int, size: Int) async throws -> PageState<ChallengeSummary>
  func searchChallenge(byName name: String, page: Int, size: Int) async throws -> PageState<ChallengeSummary>
  func searchChallenge(byHashTag hashtag: String, page: Int, size: Int) async throws -> PageState<ChallengeSummary>
  func searchHistory() -> [String]
  @discardableResult func saveSearchKeyword(_ keyword: String) -> [String]
  @discardableResult func deleteSearchKeyword(_ keyword: String) -> [String]
  func clearSearchHistory()
  func isLogin() async -> Bool
}
