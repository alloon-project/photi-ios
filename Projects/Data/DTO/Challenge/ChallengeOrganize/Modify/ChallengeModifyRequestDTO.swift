//
//  ChallengeModifyRequestDTO.swift
//  Data
//
//  Created by 임우섭 on 6/6/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ChallengeModifyRequestDTO: Encodable {
  public let name: String
  public let goal: String
  public let proveTime: String
  public let endDate: String
  public let preSignedUrl: String
  public let rules: [RuleResponseDTO]
  public let hashtags: [HashTagResponseDTO]
  
  public init(
    name: String,
    goal: String,
    proveTime: String,
    endDate: String,
    preSignedUrl: String,
    rules: [String],
    hashtags: [String]
  ) {
    self.name = name
    self.goal = goal
    self.proveTime = proveTime
    self.endDate = endDate
    self.preSignedUrl = preSignedUrl
    self.rules = rules.map { .init(rule: $0) }
    self.hashtags = hashtags.map { .init(hashtag: $0) }
  }
}
