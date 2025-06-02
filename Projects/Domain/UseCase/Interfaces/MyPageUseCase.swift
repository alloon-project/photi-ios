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

public enum PageFeedHistory {
  case `defaults`([FeedHistory])
  case lastPage([FeedHistory])
  
  public var feeds: [FeedHistory] {
    switch self {
      case .defaults(let values), .lastPage(let values):
        return values
    }
  }
}

public protocol MyPageUseCase {
  func loadMyPageSummry() -> Single<MyPageSummary>
  func loadVerifiedChallengeDates() -> Single<[Date]>
  func loadFeedHistory(page: Int, size: Int) async throws -> PageFeedHistory
}
