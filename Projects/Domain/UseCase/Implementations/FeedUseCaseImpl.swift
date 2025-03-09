//
//  FeedUseCaseImpl.swift
//  Domain
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift
import Entity
import UseCase
import Repository

public struct FeedUseCaseImpl: FeedUseCase {
  private let repository: FeedRepository
  
  public init(repository: FeedRepository) {
    self.repository = repository
  }
  
  public func fetchFeeds(page: Int, size: Int) -> Single<FeedHistory> {
    return repository.fetchFeedHistory(page: page, size: size)
  }
}
