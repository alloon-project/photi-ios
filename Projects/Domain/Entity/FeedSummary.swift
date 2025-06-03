//
//  FeedHistory.swift
//  Domain
//
//  Created by 임우섭 on 2/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct FeedSummary {
  public let feedId: Int
  public let challengeId: Int
  public let imageUrl: URL?
  public let createdDate: Date
  public let proveTime: Date
  public let invitationCode: String
  public let name: String
  
  public init(
    feedId: Int,
    challengeId: Int,
    imageUrl: URL?,
    createdDate: Date,
    invitationCode: String,
    name: String
  ) {
    self.feedId = feedId
    self.challengeId = challengeId
    self.imageUrl = imageUrl
    self.createdDate = createdDate
    self.invitationCode = invitationCode
    self.name = name
    self.proveTime = Date()
  }
  
  public init(
    feedId: Int,
    challengeId: Int,
    imageUrl: URL?,
    proveTime: Date,
    name: String
  ) {
    self.feedId = feedId
    self.challengeId = challengeId
    self.imageUrl = imageUrl
    self.proveTime = proveTime
    self.name = name

    self.createdDate = Date()
    self.invitationCode = ""
  }
}
