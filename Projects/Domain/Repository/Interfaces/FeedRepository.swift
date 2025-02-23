//
//  FeedRepository.swift
//  Domain
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity

public protocol FeedRepository {
  func fetchFeedHistory(page: Int, size: Int) -> Single<[FeedHistory]>
}
