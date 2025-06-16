//
//  ChallengeModifyPayload.swift
//  Domain
//
//  Created by 임우섭 on 6/6/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeModifyPayload {
  public let name: String
  public let goal: String
  public let proveTime: String
  public let endDate: String
  public let rules: [String]
  public let hashtags: [String]
  public let image: Data
  public let imageType: String
  
  public init(
    name: String,
    goal: String,
    proveTime: String,
    endDate: String,
    rules: [String],
    hashtags: [String],
    image: Data,
    imageType: String
  ) {
    self.name = name
    self.goal = goal
    self.proveTime = proveTime
    self.endDate = endDate
    self.rules = rules
    self.hashtags = hashtags
    self.image = image
    self.imageType = imageType
  }
  
  public func toJSONString() -> String? {
    let dict: [String: Any] = [
      "name": self.name,
      "goal": self.goal,
      "proveTime": self.proveTime.replacingOccurrences(of: " ", with: ""),
      "endDate": self.endDate.replacingOccurrences(of: ". ", with: "-"),
      "rules": self.rules.map { ["rule": $0] },
      "hashtags": self.hashtags.map { ["hashtag": $0] }
    ]
    
    guard let data = try? JSONSerialization.data(withJSONObject: dict),
          let jsonString = String(data: data, encoding: .utf8) else {
      return nil
    }
    
    return jsonString
  }
}
