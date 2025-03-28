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
  public let challengeId: Int
  public let imageUrl: URL?
  public let provedDate: Date
  public let name: String
  
  public init(feedId: Int, challengeId: Int, imageUrl: URL?, provedDate: Date, name: String) {
    self.feedId = feedId
    self.challengeId = challengeId
    self.imageUrl = imageUrl
    self.provedDate = provedDate
    self.name = name
  }
}
