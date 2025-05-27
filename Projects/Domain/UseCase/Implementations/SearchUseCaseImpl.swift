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
    let (challenges, isLast) = try await challengeRepository.fetchChallenges(
      byHashTag: hashTag,
      page: page,
      size: size
    )
   
    return isLast ? .lastPage(challenges) : .defaults(challenges)
  }
  
  func didJoinedChallenge(id: Int) async throws -> Bool {
    do {
      let myChallenges = try await challengeRepository.fetchMyChallenges(page: 0, size: 20).value
        .map { $0.id }
      
      guard myChallenges.count < 20 else {
        throw APIError.challengeFailed(reason: .exceedMaxChallengeCount)
      }
      
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
