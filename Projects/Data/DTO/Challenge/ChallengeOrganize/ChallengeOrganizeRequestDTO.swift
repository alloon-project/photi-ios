//
//  ChallengeOrganizeRequestDTO.swift
//  Data
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeOrganizeRequestDTO: Encodable {
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
  
  public func toParameters() -> [String: Any] {
    return [
      "name": self.name,
      "isPublic": self.isPublic,
      "goal": self.goal,
      "proveTime": self.proveTime,
      "endDate": self.endDate,
      "rules": self.rules.map { ["rules": $0] },
      "hashtags": self.hashtags.map { ["hashtags": $0] }
    ]
  }
}
