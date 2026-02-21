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
  public var imageURL: String
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
    self.proveTime = proveTime.replacingOccurrences(of: " ", with: "")
    self.endDate = ChallengeModifyPayload.normalizeDate(endDate)
    self.rules = rules
    self.hashtags = hashtags
  }
  
  private static func normalizeDate(_ date: String) -> String {
    let formatter = DateFormatter()
    let value = date.replacingOccurrences(of: " ", with: "")
    formatter.locale = Locale(identifier: "en_US_POSIX")

    // 허용할 입력 포맷들
    let inputFormats = [
      "yyyy-MM-dd",
      "yyyy.MM.dd",
      "yyyy/MM/dd"
    ]

    for format in inputFormats {
      formatter.dateFormat = format
      if let date = formatter.date(from: value.trimmingCharacters(in: .whitespaces)) {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
      }
    }

    return value.replacingOccurrences(of: " ", with: "")
  }
}
