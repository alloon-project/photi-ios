//
//  ChallengeOrganizePayload.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ChallengeOrganizePayload {
  public let name: String
  public let isPublic: Bool
  public let goal: String
  public let proveTime: String
  public let endDate: String
  public let imageURL: String
  public let rules: [String]
  public let hashtags: [String]
  
  public init(
    name: String,
    isPublic: Bool,
    goal: String,
    proveTime: String,
    endDate: String,
    imageURL: String,
    rules: [String],
    hashtags: [String]
  ) {
    self.name = name
    self.isPublic = isPublic
    self.goal = goal
    self.proveTime = proveTime
    self.endDate = endDate
    self.imageURL = imageURL
    self.rules = rules
    self.hashtags = hashtags
  }
}
