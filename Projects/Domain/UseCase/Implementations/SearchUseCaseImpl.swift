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
}
