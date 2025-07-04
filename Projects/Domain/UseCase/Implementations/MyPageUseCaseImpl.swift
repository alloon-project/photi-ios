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
  private let authRepository: AuthRepository
  private let myPagerepository: MyPageRepository
  
  public init(authRepository: AuthRepository, myPagerepository: MyPageRepository) {
    self.authRepository = authRepository
    self.myPagerepository = myPagerepository
  }
}

// MARK: - Fetch Methods
public extension MyPageUseCaseImpl {
  func loadMyPageSummry() -> Single<MyPageSummary> {
    return myPagerepository.fetchMyPageSummary()
  }
  
  func loadVerifiedChallengeDates() -> Single<[Date]> {
    return myPagerepository.fetchVerifiedChallengeDates()
  }
  
  func loadFeedHistory(page: Int, size: Int) async throws -> PageState<FeedSummary> {
    let result = try await myPagerepository.fetchFeedHistory(page: page, size: size)
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func loadEndedChallenges(page: Int, size: Int) async throws -> PageState<ChallengeSummary> {
    let result = try await myPagerepository.fetchEndedChallenges(page: page, size: size)
    
    return result.isLast ? .lastPage(result.contents) : .defaults(result.contents)
  }
  
  func loadFeeds(byDate date: String) async throws -> [FeedSummary] {
    return try await myPagerepository.fetchFeeds(byDate: date)
  }
  
  func logOut() {
    authRepository.removeToken()
  }
}
