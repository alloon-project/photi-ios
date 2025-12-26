//
//  ChallengeModifyPayload.swift
//  Domain
//
//  Created by 임우섭 on 6/6/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ChallengeModifyPayload {
  public let name: String
  public let goal: String
  public let imageURL: String
  public let proveTime: String
  public let endDate: String
  public let rules: [String]
  public let hashtags: [String]
  
  public init(
    name: String,
    goal: String,
    imageURL: String,
    proveTime: String,
    endDate: String,
    rules: [String],
    hashtags: [String]
  ) {
    self.name = name
    self.goal = goal
    self.imageURL = imageURL
    self.proveTime = proveTime
    self.endDate = endDate
    self.rules = rules
    self.hashtags = hashtags
  }
}
