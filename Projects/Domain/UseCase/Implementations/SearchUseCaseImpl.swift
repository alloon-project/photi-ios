//
//  SearchUseCaseImpl.swift
//  UseCaseImpl
//
//  Created by jung on 5/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity
import UseCase
import Repository

public final class SearchUseCaseImpl: SearchUseCase {
  private let challengeRepository: ChallengeRepository
  private let searchHistoryRepository: SearchHistoryRepository
  private let maximumChallengeCount = 20
  
  public init(
    challengeRepository: ChallengeRepository,
    searchHistoryRepository: SearchHistoryRepository
  ) {
    self.challengeRepository = challengeRepository
    self.searchHistoryRepository = searchHistoryRepository
  }
}

// MARK: - Fetch Methods
public extension SearchUseCaseImpl {
  func popularChallenges() -> Single<[ChallengeDetail]> {
    return challengeRepository.fetchPopularChallenges()
  }
  
  func popularHashtags() -> Single<[String]> {
    return challengeRepository.fetchPopularHashTags()
  }
  
  func challenges(
    byHashTag hashTag: String,
    page: Int,
    size: Int
  ) async throws -> PageState<ChallengeSummary> {
    let result = try await challengeRepository.fetchChallenges(
      byHashTag: hashTag,
      page: page,
      size: size
    )
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func recentChallenges(page: Int, size: Int) async throws -> PageState<ChallengeSummary> {
    let result = try await challengeRepository.fetchRecentChallenges(page: page, size: size)
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func searchChallenge(byName name: String, page: Int, size: Int) async throws -> PageState<ChallengeSummary> {
    let result = try await challengeRepository.searchChallenge(
      byName: name,
      page: page,
      size: size
    )
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func searchChallenge(byHashTag hashtag: String, page: Int, size: Int) async throws -> PageState<ChallengeSummary> {
    let result = try await challengeRepository.searchChallenge(
      byHashTag: hashtag,
      page: page,
      size: size
    )
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func didJoinedChallenge(id: Int) async throws -> Bool {
    do {
      let myChallenges = try await challengeRepository.fetchMyChallenges(page: 0, size: 20).value
        .map { $0.id }
      
      return myChallenges.contains(id)
    } catch {
      if let error = error as? APIError, case .authenticationFailed = error {
        return false
      } else {
        throw error
      }
    }
  }
  
  func isPossibleToCreateChallenge() async -> Bool {
    let myChallengeCount = try? await challengeRepository.fetchMyChallenges(page: 0, size: 20).value
      .count
    
    guard let myChallengeCount else { return true }
    
    return myChallengeCount < maximumChallengeCount
  }
  
  func searchHistory() -> [String] {
    return searchHistoryRepository.fetchAll()
  }
}

// MARK: - Update Methods
public extension SearchUseCaseImpl {
  @discardableResult func saveSearchKeyword(_ keyword: String) -> [String] {
    var searchHistories = searchHistoryRepository.fetchAll()
    searchHistories.removeAll { $0 == keyword }
    searchHistories.insert(keyword, at: 0)
    let newSearchHistories = Array(searchHistories.prefix(10))
    searchHistoryRepository.save(keywords: newSearchHistories)
    
    return newSearchHistories
  }
  
  @discardableResult func deleteSearchKeyword(_ keyword: String) -> [String] {
    return searchHistoryRepository.remove(keyword: keyword)
  }
  
  func clearSearchHistory() {
    searchHistoryRepository.removeAll()
  }
}
