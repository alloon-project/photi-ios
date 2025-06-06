//
//  MyPageUseCase.swift
//  Domain
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import Entity

public protocol MyPageUseCase {
  func loadMyPageSummry() -> Single<MyPageSummary>
  func loadVerifiedChallengeDates() -> Single<[Date]>
  func loadFeedHistory(page: Int, size: Int) async throws -> PageState<FeedSummary>
  func loadEndedChallenges(page: Int, size: Int) async throws -> PageState<ChallengeSummary>
  func loadFeeds(byDate date: String) async throws -> [FeedSummary]
  func logOut()
}
