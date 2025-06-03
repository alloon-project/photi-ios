//
//  MyPageRepository.swift
//  Domain
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import Entity

public protocol MyPageRepository {
  func fetchMyPageSummary() -> Single<MyPageSummary>
  func fetchVerifiedChallengeDates() -> Single<[Date]>
  func fetchFeedHistory(page: Int, size: Int) async throws -> PaginationResultType<FeedSummary>
  func fetchEndedChallenges(page: Int, size: Int) async throws -> PaginationResultType<ChallengeSummary>
  func fetchFeeds(byDate date: String) async throws -> [FeedSummary]
}
