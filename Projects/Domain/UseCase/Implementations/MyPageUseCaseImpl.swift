//
//  MyPageUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import Entity
import UseCase
import Repository

public class MyPageUseCaseImpl: MyPageUseCase {
  private let repository: MyPageRepository
  
  public init(repository: MyPageRepository) {
    self.repository = repository
  }
}

// MARK: - Fetch Methods
public extension MyPageUseCaseImpl {
  func loadMyPageSummry() -> Single<MyPageSummary> {
    return repository.fetchMyPageSummary()
  }
  
  func loadVerifiedChallengeDates() -> Single<[Date]> {
    return repository.fetchVerifiedChallengeDates()
  }
  
  func loadFeedHistory(page: Int, size: Int) async throws -> PageState<FeedSummary> {
    let result = try await repository.fetchFeedHistory(page: page, size: size)
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func loadEndedChallenges(page: Int, size: Int) async throws -> PageState<ChallengeSummary> {
    let result = try await repository.fetchEndedChallenges(page: page, size: size)
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
}
