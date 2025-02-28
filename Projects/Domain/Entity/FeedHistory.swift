//
//  FeedHistory.swift
//  Domain
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct FeedHistory {
  public let feedId: Int
  public let challengeId: String
  public let imageUrl: URL?
  public let provedDate: Date
  public let name: String
  
  public init(
    feedId: Int,
    challengeId: String,
    imageUrl: URL?,
    createDate: Date,
    name: String
  ) {
    self.feedId = feedId
    self.challengeId = challengeId
    self.imageUrl = imageUrl
    self.provedDate = createDate
    self.name = name
  }
}

// MARK: - Initializers
public extension FeedHistory {}
