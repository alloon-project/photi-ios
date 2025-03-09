//
//  FeedHistory.swift
//  Domain
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct FeedHistory {
  public let isLast: Bool
  public let content: [FeedInfo]
  
  public init(isLast: Bool, content: [FeedInfo]) {
    self.isLast = isLast
    self.content = content
  }
}

public struct FeedInfo {
  public let feedId: Int
  public let challengeId: Int
  public let imageUrl: URL?
  public let provedDate: Date
  public let name: String
  
  public init(
    feedId: Int,
    challengeId: Int,
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
