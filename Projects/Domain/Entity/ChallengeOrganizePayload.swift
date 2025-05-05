//
//  ChallengeOrganizePayload.swift
//  Domain
//
//  Created by 임우섭 on 5/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeOrganizePayload {
  public let name: String
  public let isPublic: Bool
  public let goal: String
  public let proveTime: String
  public let endDate: String
  public let rules: [String]
  public let hashtags: [String]
  public let image: Data
  public let imageType: String
  
  public init(
    name: String,
    isPublic: Bool,
    goal: String,
    proveTime: String,
    endDate: String,
    rules: [String],
    hashtags: [String],
    image: Data,
    imageType: String
  ) {
    self.name = name
    self.isPublic = isPublic
    self.goal = goal
    self.proveTime = proveTime
    self.endDate = endDate
    self.rules = rules
    self.hashtags = hashtags
    self.image = image
    self.imageType = imageType
  }
}
