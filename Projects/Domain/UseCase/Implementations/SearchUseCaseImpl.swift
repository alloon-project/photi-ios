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
  private let maximumChallengeCount = 20
  
  public init(challengeRepository: ChallengeRepository) {
    self.challengeRepository = challengeRepository
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
  ) async throws -> PageSearchChallenges {
    let result = try await challengeRepository.fetchChallenges(
      byHashTag: hashTag,
      page: page,
      size: size
    )
   
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func recentChallenges(page: Int, size: Int) async throws -> PageSearchChallenges {
    let result = try await challengeRepository.fetchRecentChallenges(page: page, size: size)
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func searchChallenge(byName name: String, page: Int, size: Int) async throws -> PageSearchChallenges {
    let result = try await challengeRepository.searchChallenge(
      byName: name,
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
}
