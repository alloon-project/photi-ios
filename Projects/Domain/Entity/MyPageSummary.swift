//
//  MyPageSummary.swift
//  Domain
//
//  Created by 임우섭 on 10/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation

public struct MyPageSummary {
  public let userName: String
  public let imageUrl: URL?
  public let feedCount: Int
  public let endedChallengeCount: Int
  public let registerDate: Date
  
  public init(
    userName: String,
    imageUrl: URL?,
    feedCnt: Int,
    endedChallengeCnt: Int,
    registerDate: Date
  ) {
    self.userName = userName
    self.imageUrl = imageUrl
    self.feedCount = feedCnt
    self.endedChallengeCount = endedChallengeCnt
    self.registerDate = registerDate
  }
}
