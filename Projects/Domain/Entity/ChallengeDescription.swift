//
//  ChallengeDescription.swift
//  Entity
//
//  Created by jung on 3/12/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

public struct ChallengeDescription {
  public let id: Int
  public let rules: [String]
  public let proveTime: Date
  public let startDate: Date
  public let goal: String
  public let endDate: Date
  
  public init(
    id: Int,
    rules: [String],
    proveTime: Date,
    startDate: Date,
    goal: String,
    endDate: Date
  ) {
    self.id = id
    self.rules = rules
    self.proveTime = proveTime
    self.startDate = startDate
    self.goal = goal
    self.endDate = endDate
  }
}
