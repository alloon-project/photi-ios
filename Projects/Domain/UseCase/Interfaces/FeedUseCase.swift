//
//  FeedUseCase.swift
//  UseCase
//
//  Created by jung on 2/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Entity

public protocol FeedUseCase {
  func fetchFeed(challengeId: Int, feedId: Int) async throws -> Feed
  func isLike(challengeId: Int, feedId: Int) async -> Bool
}
